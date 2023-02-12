class Outcome < Transaction
  validates :frequency, absence: true
  validates :purchase_date, presence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  after_create :update_current_balance, if: -> { transaction_type.eql?('current') }
  after_create :generate_payment, if: -> { transaction_type.eql?('current') }

  private

  def update_current_balance
    balance.current_amount -= amount
    balance.save
  end

  def generate_payment
    payments.create!(amount: self.amount, status: :applied)
  end
end
