require 'rails_helper'

RSpec.describe Outcome, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should have_db_column(:purchase_date).of_type(:datetime) }
  end

  describe 'validations' do
    it { should_not allow_value(:monthly).for(:frequency).on(:create) }
    it { should allow_value(Time.zone.today).for(:purchase_date).on(:create) }

    # describe 'when paymentable transaction_type is :fixed' do
    #   let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
    #   let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

    #   it "should validate presence of 'quotas'" do
    #     outcome = Outcome.new(balance: balance, )
    #   end
    # end
  end
end
