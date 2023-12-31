class BalancePayment < ApplicationRecord
  belongs_to :balance
  belongs_to :payment
end
