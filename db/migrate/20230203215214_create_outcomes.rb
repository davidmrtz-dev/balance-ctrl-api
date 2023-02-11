class CreateOutcomes < ActiveRecord::Migration[6.1]
  def change
    create_table :outcomes do |t|
      t.references :balance, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.datetime :purchase_date, null: false
      t.timestamps
    end
  end
end
