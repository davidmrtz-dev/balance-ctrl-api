require 'rails_helper'

RSpec.describe BillingTransaction, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:billing) }
    it { is_expected.to belong_to(:related_transaction).class_name('Transaction').with_foreign_key(:transaction_id) }
  end
end
