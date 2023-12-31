class CreateBalancePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :balance_payments do |t|
      t.references :balance, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
