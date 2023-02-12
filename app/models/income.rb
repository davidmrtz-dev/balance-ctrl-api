class Income < Transaction
  validates :frequency, presence: true
  validates :purchase_date, absence: true
  validates :quotas, absence: true
end
