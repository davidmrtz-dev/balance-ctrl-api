class CreateBillingPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :billing_informations_payments do |t|
      t.references :billing_information, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
