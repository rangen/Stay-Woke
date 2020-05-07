class UpdatePolsUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password, :string
    add_column :politicians, :facebook, :string
    add_column :politicians, :instagram, :string
    add_column :politicians, :email, :string
    add_column :politicians, :youtube, :string
  end
end
