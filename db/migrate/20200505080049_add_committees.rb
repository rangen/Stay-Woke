class AddCommittees < ActiveRecord::Migration[5.2]
  def change
    create_table :committees do |t|
      t.string :fec_id
      t.string :name

    end
  end
end
