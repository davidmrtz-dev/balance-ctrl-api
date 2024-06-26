require 'administrate/base_dashboard'

class BalanceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    balance_payments: Field::HasMany,
    current_amount: Field::String.with_options(searchable: false),
    description: Field::Text,
    incomes: Field::HasMany,
    month: Field::Number,
    outcomes: Field::HasMany,
    payments: Field::HasMany,
    title: Field::String,
    transactions: Field::HasMany,
    user: Field::BelongsTo,
    year: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    amount_incomes: Field::Number,
    amount_outcomes_current: Field::Number,
    amount_outcomes_fixed: Field::Number,
    amount_after_payments: Field::Number,
    amount_paid: Field::Number,
    amount_to_be_paid: Field::Number,
    amount_for_payments: Field::Number,
    comparison_percentage: Field::String,
    current?: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    balance_payments
    current_amount
    description
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    balance_payments
    current_amount
    description
    incomes
    month
    outcomes
    payments
    title
    transactions
    user
    year
    created_at
    updated_at
    amount_incomes
    amount_outcomes_current
    amount_outcomes_fixed
    amount_after_payments
    amount_paid
    amount_to_be_paid
    amount_for_payments
    comparison_percentage
    current?
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    balance_payments
    current_amount
    description
    incomes
    month
    outcomes
    payments
    title
    transactions
    user
    year
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how balances are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(balance)
  #   "Balance ##{balance.id}"
  # end
end
