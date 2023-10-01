class Billing < ApplicationRecord
  belongs_to :user
  has_many :billing_transactions
  has_many :related_transactions, through: :billing_transactions

  enum card_type: { credit: 0, debit: 1 }, _default: :credit

  validates :name, presence: true
  validates :state_date, presence: true
  validates :card_type, presence: true
end
