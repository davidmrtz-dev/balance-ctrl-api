class BillingInformation < ApplicationRecord
  belongs_to :user

  enum card_type: { debit: 0, credit: 1 }

  validates :name, presence: true
  validates :state_date, presence: true
  validates :card_type, presence: true
end
