require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:balances).dependent(:destroy) }
    it { is_expected.to have_many(:billings).dependent(:destroy) }
  end

  describe '#current_balance' do
    let(:user) { UserFactory.create }
    let!(:balance) { BalanceFactory.create(user: user) }

    it 'should return the first balance' do
      expect(user.current_balance).to eq(balance)
    end
  end
end
