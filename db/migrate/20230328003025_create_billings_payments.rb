class CreateBillingsPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :billings_payments do |t|
      t.references :billing, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
