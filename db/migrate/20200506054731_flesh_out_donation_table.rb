class FleshOutDonationTable < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :zip, :integer
    add_column :donations, :entity_type, :string
    add_column :donations, :name, :string
  end
end
