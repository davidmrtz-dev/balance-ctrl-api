class Transaction < ApplicationRecord
  include Discard::Model

  before_update :remove_previous_categorizations, if: :should_remove_previous_categorizations?
  before_update :remove_previous_billing_transactions, if: :should_remove_previous_billing_transactions?
  before_discard :validate_transaction_date_in_current_month
  after_update :update_payment, if: -> { transaction_type.eql?('current') && payments.applied.any? }

  belongs_to :balance
  has_many :payments, as: :paymentable, dependent: :destroy
  has_many :billing_transactions, dependent: :destroy
  has_many :billings, through: :billing_transactions
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  enum transaction_type: { current: 0, fixed: 1 }, _default: :current
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }

  validates :transaction_date, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  validate :transaction_date_not_after_today, :transaction_date_current_month
  validate :only_one_billing, on: :update
  validate :billing_transaction_changed, on: :update, if: -> { billings.any? && billing_transactions.last.new_record? }

  scope :with_balance_and_user, -> { joins(balance: :user) }
  scope :from_user, ->(user) { where({ balance: { user: user } }) }
  scope :by_transaction_date, -> { order(transaction_date: :desc, id: :desc) }

  default_scope -> { kept }

  accepts_nested_attributes_for :categorizations
  accepts_nested_attributes_for :billing_transactions

  def current_billing
    return unless billings.any?

    billings.first
  end

  private

  def transaction_date_not_after_today
    return if transaction_date.nil? || transaction_date <= Time.zone.now.beginning_of_day

    errors.add(:transaction_date, 'cannot be after today')
  end

  def transaction_date_current_month
    return if transaction_date.nil? || transaction_date.month == Time.zone.now.month

    errors.add(:transaction_date, 'should be in current month')
  end

  def remove_previous_categorizations
    categorizations.each do |categorization|
      categorization.destroy! if categorization.persisted?
    end
  end

  # If new category is set and there are previous categories return true
  def should_remove_previous_categorizations?
    categorizations.any?(&:persisted?) && categorizations.any?(&:new_record?)
  end

  def remove_previous_billing_transactions
    billing_transactions.each do |billing_transaction|
      billing_transaction.destroy! if billing_transaction.persisted?
    end
  end

  # If new billing is set and there are previous billings return true
  def should_remove_previous_billing_transactions?
    billing_transactions.any?(&:persisted?) &&
      billing_transactions.any?(&:new_record?) &&
      transaction_type.eql?('current')
  end

  def only_one_billing
    return unless billing_transactions.count > 1

    errors.add(
      :billing_transactions, 'Only one billing is allowed per transaction'
    )
  end

  def billing_transaction_changed
    return unless current_billing.eql?(billing_transactions.last.billing)

    errors.add(:base, 'New billing should be different from previous')
  end

  def validate_transaction_date_in_current_month
    return unless transaction_date.month != Time.zone.now.month

    errors.add(:base, 'Can only delete outcomes created in the current month')
    raise Errors::UnprocessableEntity, errors.full_messages.join(', ')
  end

  def update_payment
    payments.applied.first.update!(amount: amount)
  end
end
