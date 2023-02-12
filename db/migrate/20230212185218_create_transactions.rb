class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :balance, null: false, foreign_key: true
      t.string :type, null: false, index: true
      t.integer :transaction_type, null: false, default: :current
      t.string :description
      t.integer :frequency
      t.datetime :purchase_date
      t.timestamps
    end
  end
end
