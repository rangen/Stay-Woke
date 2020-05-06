class AddFecIdToPolitician < ActiveRecord::Migration[5.2]
  def change
    add_column :politicians, :candidate_id, :string
  end
end
