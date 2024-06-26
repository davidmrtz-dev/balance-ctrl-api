class Income < Transaction
  after_create :generate_payment
  after_discard :generate_refund

  validates :quotas, absence: true
  validates :frequency, absence: true, if: -> { transaction_type.eql?('current') }
  validates :frequency, presence: true, if: -> { transaction_type.eql?('fixed') }

  private

  def generate_payment
    return unless transaction_type.eql? 'current'

    payment = payments.create!(amount: amount, status: :hold, paid_at: transaction_date)
    BalancePayment.create!(balance: balance, payment: payment)
    payment.applied!
  end

  def generate_refund
    return unless transaction_type.eql? 'current'

    payments.applied.each do |p|
      p.create_refund!(paymentable: self, amount: p.amount)
      BalancePayment.create!(balance: balance, payment: p.refund)
      p.refund.update!(status: :refund)
      p.save!
    end
  end
end
