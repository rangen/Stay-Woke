class CreateJoinForPolsAndComs < ActiveRecord::Migration[5.2]
  def change
    create_join_table :politicians, :committees
    add_column :politicians, :name, :string
    remove_column :politicians, :first_name
    remove_column :politicians, :last_name
  end
end
