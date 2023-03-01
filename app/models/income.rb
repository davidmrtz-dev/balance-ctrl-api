class Income < Transaction
  validates :frequency, presence: true, if: -> { transaction_type.eql?('fixed') }
  validates :frequency, absence: true, if: -> { transaction_type.eql?('current') }
  validates :purchase_date, absence: true
  validates :quotas, absence: true

  after_create :add_balance_amount, if: -> { transaction_type.eql?('current') }
  before_destroy :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  before_save :update_balance_amount, if: -> { transaction_type.eql?('current') && amount_was > 0 }

  default_scope -> { order(created_at: :desc) }

  private

  def substract_balance_amount
    balance.current_amount -= amount
    balance.save
  end

  def update_balance_amount
    balance.current_amount += (amount - amount_was)
    balance.save
  end

  def add_balance_amount
    balance.current_amount += amount
    balance.save
  end
end
