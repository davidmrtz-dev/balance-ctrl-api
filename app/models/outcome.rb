class Outcome < Transaction
  validates :frequency, absence: true
  validates :purchase_date, presence: true
  # validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }
end
