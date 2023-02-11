class CreateIncomes < ActiveRecord::Migration[6.1]
  def change
    create_table :incomes do |t|
      t.references :balance, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.integer :income_frequency, null: false
      t.integer :active_type, null: false
      t.decimal :amount, { precision: 10, scale: 2 }, default: '0.0', null: false
      t.timestamps
    end
  end
end
