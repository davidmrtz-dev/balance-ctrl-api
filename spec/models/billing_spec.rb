require 'rails_helper'

RSpec.describe Billing, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { should define_enum_for(:card_type).with_values(%i[debit credit]) }
    it { is_expected.to have_many(:billing_transactions) }
    it { is_expected.to have_many(:related_transactions).through(:billing_transactions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:state_date) }
    it { should validate_presence_of(:card_type) }
  end
end
