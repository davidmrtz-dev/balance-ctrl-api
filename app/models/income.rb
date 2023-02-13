class Income < Transaction
  validates :frequency, presence: true
  validates :purchase_date, absence: true
  validates :quotas, absence: true

  before_destroy :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  after_create :add_balance_amount, if: -> { transaction_type.eql?('current') }

  private

  def substract_balance_amount
    balance.current_amount -= amount
    balance.save
  end

  def add_balance_amount
    balance.current_amount += amount
    balance.save
  end
end
