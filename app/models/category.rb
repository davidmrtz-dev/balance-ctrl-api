class Category < ApplicationRecord
  include Discard::Model

  has_many :categorizations
  has_many :transactions_records, through: :categorizations, source: :transaction_record

  validates :name, presence: true, uniqueness: true

  default_scope -> { order(created_at: :desc) }
end
