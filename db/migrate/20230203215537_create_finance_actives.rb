class CreateFinanceActives < ActiveRecord::Migration[6.1]
  def change
    create_table :finance_actives do |t|
      t.references :balance, null: false, foreign_key: true
      t.integer :income_frequency
      t.date :income_date
      t.decimal :amount, { precision: 10, scale: 2 }
      t.timestamps
    end
  end
end
