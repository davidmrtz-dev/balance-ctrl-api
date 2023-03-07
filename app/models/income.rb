class Income < Transaction
  validates :quotas, absence: true
  validates :frequency, absence: true, if: -> { transaction_type.eql?('current') }
  validates :frequency, presence: true, if: -> { transaction_type.eql?('fixed') }

  validate :transaction_date_not_after_today, on: :create

  after_create :add_balance_amount, if: -> { transaction_type.eql?('current') }
  before_destroy :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  before_save :update_balance_amount, if: -> { transaction_type.eql?('current') && amount_was > 0 }

  default_scope -> { order(created_at: :desc) }

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
    balance.current_amount += (amount - amount_was)
    balance.save
    payments.first.update!(amount: amount)
  end

  def add_balance_amount
    balance.current_amount += amount
    balance.save
  end
end
