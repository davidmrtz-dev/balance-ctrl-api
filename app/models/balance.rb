class Balance < ApplicationRecord
  belongs_to :user
  has_many :finance_obligations, dependent: :destroy
  has_many :finance_actives, dependent: :destroy
end
