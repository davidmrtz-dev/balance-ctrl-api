class Outcome < Transaction
  before_save :update_balance_amount, if: -> { transaction_type.eql?('current') && amount_was.positive? }
  after_create :generate_payments, if: -> { transaction_type.eql?('fixed') }
  after_create :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  before_destroy :add_balance_amount, if: -> { transaction_type.eql?('current') }

  validates :frequency, absence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  scope :current_types, -> { where(transaction_type: :current) }
  scope :fixed_types, -> { where(transaction_type: :fixed) }
  scope :by_transaction_date, -> { order(transaction_date: :desc, id: :desc) }

  def status
    return :expired if payments.any? { |payment| payment.status == 'expired' }
    return :pending if payments.any? { |payment| payment.status == 'pending' }
    return :hold if payments.all? { |payment| payment.status == 'hold' } && payments.present?
    return :paid if payments.all? { |payment| payment.status == 'applied' } && payments.present?
    return :ok if payments.all? { |payment| payment.status.in?(['ok', 'hold']) } && payments.present?

    :unknown
  end

  private

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
