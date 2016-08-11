require_relative '../bin/active_record_lite'

class User < SQLObject
  finalize!


  has_many :cats,
    primary_key: :id,
    foreign_key: :owner_id,
    class_name: :Cat


end
