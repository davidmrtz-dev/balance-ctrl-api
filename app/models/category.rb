class Category < ApplicationRecord
  has_many :categorizations
  has_many :transactions_records, through: :categorizations, source: :transaction_record

  validates :name, presence: true, uniqueness: true
end
