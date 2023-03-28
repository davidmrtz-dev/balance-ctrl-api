require 'rails_helper'

RSpec.describe BillingInformation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { should define_enum_for(:card_type).with_values(%i[debit credit]) }
    it { should have_and_belong_to_many(:payments) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:state_date) }
    it { should validate_presence_of(:card_type) }
  end
end
