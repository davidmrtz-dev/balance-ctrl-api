class CreateBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :balances do |t|
      t.references :user
      t.string :title
      t.text :description
      t.timestamps
    end
  end
end
