class Outcome < Transaction
  before_save :update_balance_amount, if: -> { transaction_type.eql?('current') && amount_was.positive? }
  after_create :generate_payment, if: -> { transaction_type.eql? 'current' }
  after_create :generate_payments, if: -> { transaction_type.eql?('fixed') }
  after_create :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  before_update :remove_previous_categorizations, if: :should_remove_previous_categorizations?
  before_update :remove_previous_billing_transactions, if: :should_remove_previous_billing_transactions?
  before_destroy :add_balance_amount, if: -> { transaction_type.eql?('current') }
  before_destroy :check_same_month, if: -> { transaction_type.eql? 'current' }
  before_discard :check_same_month, if: -> { transaction_type.eql? 'fixed' }

  validates :frequency, absence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }
  validate :only_one_billing, on: :update

  scope :current_types, -> { where(transaction_type: :current) }
  scope :fixed_types, -> { where(transaction_type: :fixed) }
  scope :by_transaction_date, -> { order(transaction_date: :desc, id: :desc) }

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def status
    return :expired if payments.any? { |payment| payment.status == 'expired' }
    return :pending if payments.any? { |payment| payment.status == 'pending' }
    return :hold if payments.all? { |payment| payment.status == 'hold' } && payments.present?
    return :paid if payments.all? { |payment| payment.status == 'applied' } && payments.present?
    return :ok if payments.all? { |payment| payment.status.in?(%w[ok hold]) } && payments.present?

    :unknown
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  def generate_payment
    payments.create!(amount: amount, status: :applied)
  end

  def check_same_month
    return unless created_at.month != Time.zone.now.month

    errors.add(:base, 'Can only delete outcomes created in the current month')
    throw :abort
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
    amount_for_quota = amount / quotas

    quotas.times do
      payments.create!(amount: amount_for_quota)
    end
  end
end
