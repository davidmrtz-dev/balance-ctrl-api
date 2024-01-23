class Outcome < Transaction
  after_create :generate_payments
  after_discard :generate_refunds

  validates :frequency, absence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  private

  # rubocop:disable Metrics/AbcSize
  def generate_payments
    if transaction_type.eql? 'current'
      payment = payments.create!(amount: amount, status: :hold, paid_at: transaction_date)
      BalancePayment.create!(balance: balance, payment: payment)
      payment.applied!
    else
      amount_for_quota = amount / quotas

      quotas.times do
        payment = payments.create!(amount: amount_for_quota, status: :hold, paid_at: transaction_date)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def generate_refunds
    # TODO: refactor when work @refunds
    return unless transaction_type.eql? 'current'

    payments.applied.each do |p|
      p.create_refund!(paymentable: self, amount: p.amount)
      BalancePayment.create!(balance: balance, payment: p.refund)
      p.refund.update!(status: :refund)
      p.save!
    end
  end
end
