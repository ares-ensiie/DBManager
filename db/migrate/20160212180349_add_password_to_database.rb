class AddPasswordToDatabase < ActiveRecord::Migration
  def change
    add_column :databases, :password, :string
  end
end
