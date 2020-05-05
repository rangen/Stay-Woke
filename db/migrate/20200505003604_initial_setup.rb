class InitialSetup < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :addresses do |t|
      t.integer :street_number
      t.string :street_name
      t.integer :zip_code
      t.integer :user_id
      #boolean for political entities?  #timestamps for when created/updated?
    end

    create_table :politicians do |t|
      t.string  :first_name
      t.string  :last_name
      #candidate? in-office?  Other?
    end

    create_table :donations do |t|
      t.integer :donor_id
      t.integer :politician_id
      t.integer :amount
      t.datetime :date
    end

    create_table :donors do |t|
      t.string :first_name
      t.string :last_name
    end

  end
end
