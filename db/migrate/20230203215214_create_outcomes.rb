class CreateOutcomes < ActiveRecord::Migration[6.1]
  def change
    create_table :outcomes do |t|
      t.references :balance, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.datetime :purchase_date, null: false
      # t.decimal :amount, { precision: 10, scale: 2 }, default: '0.0', null: false
      t.timestamps
    end
  end
end
