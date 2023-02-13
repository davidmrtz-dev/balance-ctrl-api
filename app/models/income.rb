class Income < Transaction
  validates :frequency, presence: true
  validates :purchase_date, absence: true
  validates :quotas, absence: true

  after_create :update_balance_amount, if: -> { transaction_type.eql?('current') }

  private

  def update_balance_amount
    balance.current_amount += amount
    balance.save
  end
end
