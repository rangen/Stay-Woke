class AddSavepointsForDataCommittee < ActiveRecord::Migration[5.2]
  def change
    add_column :committees, :num_records_available, :integer
    add_column :committees, :num_records_downloaded, :integer
    add_column :committees, :last_index, :string
    add_column :committees, :last_date, :string  #leave to not break API??
    add_column :committees, :cycles_active, :string
    add_column :committees, :first_file_date, :datetime
  end
end
