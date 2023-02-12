class Income < Transaction
  # has_many :payments, as: :paymentable, dependent: :destroy
end
