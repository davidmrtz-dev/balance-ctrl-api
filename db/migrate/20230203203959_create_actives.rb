class CreateActives < ActiveRecord::Migration[6.1]
  def change
    create_table :actives do |t|
      t.references :balance, null: false, foreign_key: true
      t.date :income_date
      t.integer :income_frequency
      t.decimal :amount, { precision: 10, scale: 2 }
      t.timestamps
    end
  end
end
