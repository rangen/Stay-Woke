class UpdateCommitteeTableSchema < ActiveRecord::Migration[5.2]
  def change
    add_column :committees, :designation_full, :string
    add_column :committees, :alt_name, :string
    add_column :committees, :org_type, :string
    add_column :committees, :last_file_date, :datetime
    
  end
end
