class Outcome < Transaction
  validates :frequency, absence: true
  validates :purchase_date, presence: true
end
