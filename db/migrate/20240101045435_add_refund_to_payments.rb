class AddRefundToPayments < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    add_reference :payments, :refund, foreign_key: { to_table: :payments }
    add_column :payments, :paid_at, :datetime
    add_column :payments, :folio, :uuid, default: 'gen_random_uuid()', null: false
  end
end
