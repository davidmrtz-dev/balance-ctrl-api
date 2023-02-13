class Outcome < Transaction
  validates :frequency, absence: true
  validates :purchase_date, presence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  after_create :update_balance_amount, if: -> { transaction_type.eql?('current') }
  after_create :generate_payments, if: -> { transaction_type.eql?('fixed') }

  private

  def update_balance_amount
    balance.current_amount -= amount
    balance.save
  end

  def generate_payments
    amount_for_quota = amount / quotas

    quotas.times do
      payments.create!(amount: amount_for_quota)
    end
  end
end
