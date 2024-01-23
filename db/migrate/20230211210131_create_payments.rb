class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.references :paymentable, null: false, polymorphic: true, index: true
      t.uuid :folio, default: -> { 'gen_random_uuid()' }, null: false
      t.decimal :amount, precision: 8, scale: 2, default: '0.0', null: false
      t.integer :status, null: false
      t.timestamps
    end
  end
end
