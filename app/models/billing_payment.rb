class BillingPayment < ApplicationRecord
  belongs_to :billing_information
  belongs_to :payment
end
