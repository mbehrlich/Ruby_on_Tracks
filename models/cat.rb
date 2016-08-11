require_relative '../bin/active_record_lite'

class Cat < SQLObject
  finalize!


  belongs_to :owner,
    primary_key: :id,
    foreign_key: :owner_id,
    class_name: :User

end
