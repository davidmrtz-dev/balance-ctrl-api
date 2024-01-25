class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :balance, null: false, foreign_key: true
      t.string :type, null: false, index: true
      t.integer :transaction_type, null: false
      t.decimal :amount, precision: 10, scale: 2, default: '0.0', null: false
      t.string :description
      t.integer :frequency
      t.datetime :transaction_date
      t.integer :quotas
      t.timestamps
    end
  end
end
