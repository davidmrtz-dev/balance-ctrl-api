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

  def update_category(category_id)
    current_category = categories.first
    new_category = Category.find(category_id)

    return if current_category.eql?(new_category)

    current_category.categorizations.find_by(transaction_id: id).destroy!
    categorizations.create!(category: new_category)
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
