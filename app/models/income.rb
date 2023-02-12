class Income < Transaction
  validates :frequency, presence: true
  validates :purchase_date, absence: true
end
