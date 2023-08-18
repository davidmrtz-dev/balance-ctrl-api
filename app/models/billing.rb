class Billing < ApplicationRecord
  belongs_to :user
  # has_and_belongs_to_many :billing_transactions, class_name: 'Transaction'

  enum card_type: { debit: 0, credit: 1 }

  validates :name, presence: true
  validates :state_date, presence: true
  validates :card_type, presence: true
end
