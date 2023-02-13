class Outcome < Transaction
  validates :frequency, absence: true
  validates :purchase_date, presence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }

  after_create :update_balance_amount, if: -> { transaction_type.eql?('current') }

  private

  def update_balance_amount
    balance.current_amount -= amount
    balance.save
  end
end
