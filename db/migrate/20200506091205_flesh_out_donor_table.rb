class FleshOutDonorTable < ActiveRecord::Migration[5.2]
  def change
    add_column :donors, :occupation, :string
    add_column :donors, :street_1, :string
    add_column :donors, :street_2, :string
    add_column :donors, :zip, :integer
    add_column :donors, :city, :string
    add_column :donors, :state, :string
    add_column :donors, :employer, :string
    add_column :donors, :line_number, :string
    remove_columns :donations, :zip, :entity_type, :name

  end
end
