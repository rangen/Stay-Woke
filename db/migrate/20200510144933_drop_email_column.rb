class DropEmailColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :politicians, :email
  end
end
