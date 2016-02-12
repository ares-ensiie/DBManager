class Database < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  enum type: [:postgres, :mongodb]
end
