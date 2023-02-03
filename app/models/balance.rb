class Balance < ApplicationRecord
  belongs_to :user
  has_many :finance_obligations, dependent: :destroy
end
