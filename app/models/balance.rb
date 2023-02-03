class Balance < ApplicationRecord
  belongs_to :user
  has_many :actives, dependent: :destroy
end
