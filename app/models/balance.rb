class Balance < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :outcomes, dependent: :destroy

  scope :with_outcomes, -> { joins(:outcomes) }
  scope :current_outcomes, -> { where({ outcomes: { transaction_type: :current } }) }

  private

  def total_incomes
    incomes.sum(:amount)
  end

  def total_outcomes
    outcomes.sum(:amount)
  end
end
