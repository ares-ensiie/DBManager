class CreateDbs < ActiveRecord::Migration
  def change
    create_table :dbs do |t|
      t.string :name
      t.integer :type
      t.string :user

      t.timestamps null: false
    end
  end
end
