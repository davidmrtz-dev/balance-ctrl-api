class Categorization < ApplicationRecord
  belongs_to :transaction_record, class_name: 'Transaction', foreign_key: :transaction_id, inverse_of: :categorizations
  belongs_to :category
end
