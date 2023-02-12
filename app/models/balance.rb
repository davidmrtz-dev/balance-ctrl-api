class Balance < ApplicationRecord
  belongs_to :user
  has_many :outcomes, dependent: :destroy
  has_many :incomes, dependent: :destroy
end
