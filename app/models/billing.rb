class Billing < ApplicationRecord
  belongs_to :user
  has_many :billing_transactions
  has_many :related_transactions, through: :billing_transactions

  enum card_type: { debit: 0, credit: 1 }

  validates :name, presence: true
  validates :state_date, presence: true
  validates :card_type, presence: true
end
