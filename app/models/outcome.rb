class Outcome < Transaction
  validates :frequency, absence: true
  validates :purchase_date, presence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  after_create :generate_payment, if: -> { transaction_type.eql?('current') }

  private

  def generate_payment
    payments.create!(amount: self.amount, status: :pending)
  end
end
