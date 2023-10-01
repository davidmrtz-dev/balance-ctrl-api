class Outcome < Transaction
  before_save :update_balance_amount, if: -> { transaction_type.eql?('current') && amount_was.positive? }
  after_create :generate_payments
  after_discard :generate_refunds
  after_create :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  after_discard :add_balance_amount, if: -> { transaction_type.eql?('current') }
  before_update :remove_previous_categorizations, if: :should_remove_previous_categorizations?
  before_update :remove_previous_billing_transactions, if: :should_remove_previous_billing_transactions?
  before_discard :validate_transaction_date_in_current_month

  validates :frequency, absence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }
  validate :only_one_billing, on: :update

  scope :by_transaction_date, -> { order(transaction_date: :desc, id: :desc) }

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def status
    return :cancelled if payments.any? { |payment| payment.status == 'cancelled' }
    return :expired if payments.any? { |payment| payment.status == 'expired' }
    return :pending if payments.any? { |payment| payment.status == 'pending' }
    return :hold if payments.all? { |payment| payment.status == 'hold' }
    return :paid if payments.all? { |payment| payment.status == 'applied' }
    return :ok if payments.all? { |payment| payment.status.in?(%w[applied hold]) }

    :unknown
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  def validate_transaction_date_in_current_month
    return unless transaction_date.month != Time.zone.now.month

    errors.add(:base, 'Can only delete outcomes created in the current month')
    raise Errors::UnprocessableEntity, errors.full_messages.join(', ')
  end

  def only_one_billing
    return unless billing_transactions.count > 1

    errors.add(
      :billing_transactions, 'Only one billing is allowed per outcome'
    )
  end

  def remove_previous_categorizations
    categorizations.each do |categorization|
      categorization.destroy! if categorization.persisted?
    end
  end

  def should_remove_previous_categorizations?
    categorizations.any?(&:persisted?) && categorizations.any?(&:new_record?)
  end

  def remove_previous_billing_transactions
    billing_transactions.each do |billing_transaction|
      billing_transaction.destroy! if billing_transaction.persisted?
    end
  end

  def should_remove_previous_billing_transactions?
    billing_transactions.any?(&:persisted?) &&
      billing_transactions.any?(&:new_record?) &&
      transaction_type.eql?('current')
  end

  def substract_balance_amount
    balance.current_amount -= amount
    balance.save
  end

  def update_balance_amount
    balance.current_amount += (amount_was - amount)
    balance.save
    payments.first.update!(amount: amount)
  end

  def add_balance_amount
    balance.current_amount += amount
    balance.save
  end

  def generate_payments
    if transaction_type.eql? 'current'
      payments.create!(amount: amount, status: :applied)
    else
      amount_for_quota = amount / quotas

      quotas.times do
        payments.create!(amount: amount_for_quota)
      end
    end
  end

  def generate_refunds
    if transaction_type.eql? 'current'
      payments.create!(amount: amount, status: :refund)
    else
      payments.applied.each do |applied|
        payments.create!(amount: applied.amount, status: :refund)
      end
    end
  end
end
