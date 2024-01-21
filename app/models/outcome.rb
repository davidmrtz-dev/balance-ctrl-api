class Outcome < Transaction
  after_create :generate_payments
  after_discard :generate_refunds

  validates :frequency, absence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def status
    return :expired if payments.any? { |payment| payment.status == 'expired' }
    return :pending if payments.any? { |payment| payment.status == 'pending' }
    return :hold if payments.all? { |payment| payment.status == 'hold' }
    return :paid if payments.all? { |payment| payment.status == 'applied' }
    return :ok if payments.all? { |payment| payment.status.in?(%w[applied hold]) }

    :unknown
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  def generate_payments
    if transaction_type.eql? 'current'
      payment = payments.create!(amount: amount, status: :hold)
      BalancePayment.create!(balance: balance, payment: payment)
    else
      amount_for_quota = amount / quotas

      quotas.times do
        payment = payments.create!(amount: amount_for_quota, status: :hold)
        BalancePayment.create!(balance: balance, payment: payment)
      end
    end
  end

  def generate_refunds
    payments.applied.each do |p|
      p.create_refund!(paymentable: self, amount: p.amount)
      BalancePayment.create!(balance: balance, payment: p.refund)
      p.refund.update!(status: :refund)
      p.save!
    end
  end
end
