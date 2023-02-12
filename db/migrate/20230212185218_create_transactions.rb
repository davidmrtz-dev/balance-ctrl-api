class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :balance, null: false, foreign_key: true
      t.integer :type, null: false, default: :income
      t.integer :transaction_type, null: false, default: :current
      t.string :description
      t.integer :frequency, null: false
      t.datetime :purchase_date, null: false
      t.timestamps
    end
  end
end
