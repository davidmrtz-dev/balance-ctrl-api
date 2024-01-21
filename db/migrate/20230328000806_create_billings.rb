class CreateBillings < ActiveRecord::Migration[6.1]
  def change
    create_table :billings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :cycle_end_date
      t.date :payment_due_date
      t.integer :billing_type, null: false
      t.datetime :discarded_at, index: true
      t.string :encrypted_credit_card_number
      t.string :encrypted_credit_card_number_iv, index: true, unique: true

      t.timestamps
    end
  end
end
