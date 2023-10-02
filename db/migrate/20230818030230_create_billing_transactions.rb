class CreateBillingTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :billing_transactions do |t|
      t.references :billing, null: false, foreign_key: true
      t.references :transaction, null: false, foreign_key: true

      t.timestamps
    end

    add_index :billing_transactions, [:billing_id, :transaction_id], unique: true, name: 'unique_billing_transaction'
  end
end
