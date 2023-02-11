class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.references :outcome, null: false, foreign_key: true
      t.decimal :amount, { precision: 8, scale: 2 }, default: '0.0', null: false
      t.timestamps
    end
  end
end
