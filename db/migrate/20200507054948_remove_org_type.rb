class RemoveOrgType < ActiveRecord::Migration[5.2]
  def change
    remove_column :committees, :org_type
  end
end
