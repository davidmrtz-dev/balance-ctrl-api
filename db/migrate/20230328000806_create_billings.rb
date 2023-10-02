class CreateBillings < ActiveRecord::Migration[6.1]
  def change
    create_table :billings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :state_date
      t.integer :billing_type, null: false

      t.timestamps
    end
  end
end
