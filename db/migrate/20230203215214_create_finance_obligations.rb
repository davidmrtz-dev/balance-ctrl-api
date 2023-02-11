class CreateFinanceObligations < ActiveRecord::Migration[6.1]
  def change
    create_table :finance_obligations do |t|
      t.references :balance, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.integer :obligation_type, null: false
      t.date :charge_date, null: false
      t.decimal :amount, { precision: 10, scale: 2 }, default: '0.0', null: false
      t.timestamps
    end
  end
end
