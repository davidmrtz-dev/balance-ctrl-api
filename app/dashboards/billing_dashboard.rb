require 'administrate/base_dashboard'

class BillingDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    billing_transactions: Field::HasMany,
    billing_type: Field::Select.with_options(
      searchable: false,
      collection: lambda { |field|
                    field.resource.class.send(field.attribute.to_s.pluralize).keys
                  }
    ),
    cycle_end_date: Field::Date,
    discarded_at: Field::DateTime,
    encrypted_credit_card_number: Field::String,
    encrypted_credit_card_number_iv: Field::String,
    name: Field::String,
    payment_due_date: Field::Date,
    related_transactions: Field::HasMany,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    billing_transactions
    billing_type
    cycle_end_date
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    billing_transactions
    billing_type
    cycle_end_date
    discarded_at
    encrypted_credit_card_number
    encrypted_credit_card_number_iv
    name
    payment_due_date
    related_transactions
    user
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    billing_transactions
    billing_type
    cycle_end_date
    discarded_at
    encrypted_credit_card_number
    encrypted_credit_card_number_iv
    name
    payment_due_date
    related_transactions
    user
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

  # Overwrite this method to customize how billings are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(billing)
  #   "Billing ##{billing.id}"
  # end
end
