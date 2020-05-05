class RemoveAddressTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :addresses

    add_column :users, :street_address, :string
    add_column :users, :zip_code, :integer
  end
end
