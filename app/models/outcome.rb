class Outcome < Transaction
  validates :frequency, absence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  validate :transaction_date_not_after_today, on: :create

  scope :current_types, -> { where(transaction_type: :current) }
  scope :fixed_types, -> { where(transaction_type: :fixed) }
  scope :by_transaction_date, -> { order(transaction_date: :desc, id: :desc) }

  after_create :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  before_destroy :add_balance_amount, if: -> { transaction_type.eql?('current') }
  before_save :update_balance_amount, if: -> { transaction_type.eql?('current') && amount_was > 0 }
  after_create :generate_payments, if: -> { transaction_type.eql?('fixed') }

  private

  def transaction_date_not_after_today
    return if transaction_date.nil? || transaction_date < Time.zone.now

    errors.add(:transaction_date, 'can not be after today')
  end

  def substract_balance_amount
    balance.current_amount -= amount
    balance.save
  end

  def update_balance_amount
    balance.current_amount += (amount_was - amount)
    balance.save
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