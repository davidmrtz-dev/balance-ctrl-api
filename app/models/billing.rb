class Billing < ApplicationRecord
  include Discard::Model

  belongs_to :user
  has_many :billing_transactions
  has_many :related_transactions, through: :billing_transactions

  enum billing_type: { credit: 0, debit: 1, cash: 2 }, _default: :credit

  validates :name, presence: true
  validates :billing_type, presence: true
end
