class AddRefundToPayments < ActiveRecord::Migration[6.1]
  def change
    add_reference :payments, :refund, foreign_key: { to_table: :payments }
    add_column :payments, :paid_at, :datetime
  end
end
