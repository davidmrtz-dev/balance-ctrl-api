class CreateIncomes < ActiveRecord::Migration[6.1]
  def change
    create_table :incomes do |t|
      t.references :balance, null: false, foreign_key: true
      t.integer :income_type, null: false, default: :current
      t.string :title
      t.string :description
      t.integer :income_frequency, null: false
      t.timestamps
    end
  end
end
