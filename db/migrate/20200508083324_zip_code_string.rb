class ZipCodeString < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :zip_code, :string
  end
end
