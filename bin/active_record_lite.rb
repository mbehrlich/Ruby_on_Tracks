require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.to_s.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || "#{name}".camelcase
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = send("#{options.foreign_key}")
      target_class = options.model_class
      target_class.where(options.primary_key => foreign_key).first
    end
    assoc_options[name] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      primary_key = send("#{options.primary_key}")
      target_class = options.model_class
      target_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      source = source_options.table_name
      through = through_options.table_name
      through_id = send("#{through_name}").id
      result = DBConnection.execute(<<-SQL, through_id)
        SELECT
          #{source}.*
        FROM
          #{through}
        JOIN
          #{source} ON #{through}.#{source_options.foreign_key} = #{source}.#{source_options.primary_key.to_s}
        WHERE
          #{through}.#{through_options.primary_key.to_s} = ?
      SQL
      source_options.model_class.new(result.first)
    end
  end

end


module Searchable
  def where(params)
    where_line = []
    params.each do |attr_name, value|
      where_line << "#{attr_name} = ?"
    end
    where_line = where_line.join(' AND ')
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL
    results.map do |result|
      self.new(result)
    end
  end
end


class SQLObject

  extend Associatable
  extend Searchable

  @@finalized = false

  def self.columns
    if @columns.nil?
      table = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
        LIMIT
          0
      SQL
      @columns = table[0].map { |el| el.to_sym }
    else
      @columns
    end
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") do
        attributes[column]
      end
      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.to_s.tableize
    @table_name
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    result[0].nil? ? nil : self.new(result[0])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      # next if attr_name.to_s == "id"
      attr_sym = attr_name.to_sym
      if self.class.columns.include?(attr_sym)
        send "#{attr_sym}=", value
      else
        raise "unknown attribute '#{attr_sym}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column|
      send "#{column}"
    end
  end

  def insert
    col_names = self.class.columns.join(',')
    question_marks = (["?"] * self.class.columns.length).join(',')
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
    self.id
  end

  def update
    set_line = self.class.columns.map do |column|
      "#{column} = ?"
    end
    set_line = set_line.join(',')
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end

end
