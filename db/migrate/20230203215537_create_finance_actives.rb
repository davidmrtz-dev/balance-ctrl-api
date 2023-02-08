class CreateFinanceActives < ActiveRecord::Migration[6.1]
  def change
    create_table :finance_actives do |t|
      t.references :balance, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.integer :income_frequency
      t.integer :active_type
      t.decimal :amount, { precision: 10, scale: 2 }
      t.timestamps
    end
  end
end
