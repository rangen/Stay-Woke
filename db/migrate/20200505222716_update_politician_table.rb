class UpdatePoliticianTable < ActiveRecord::Migration[5.2]
  def change
    add_column :politicians, :twitter, :string
    add_column :politicians, :domain, :string
    add_column :politicians, :party, :string
    add_column :politicians, :title, :string
    create_join_table :politicians, :users
  end
end
