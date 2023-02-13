class Balance < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :outcomes, dependent: :destroy

  private

  def total_incomes
    incomes.sum(:amount)
  end

  def total_outcomes
    outcomes.sum(:amount)
  end
end
