class Income < Transaction
  validates :frequency, presence: true
  validates :purchase_date, absence: true
  validates :quotas, absence: true

  after_create :update_current_balance, if: -> { transaction_type.eql?('current') }

  private

  def update_current_balance
    balance.current_amount += amount
    balance.save
  end
end
