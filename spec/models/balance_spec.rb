require 'rails_helper'

RSpec.describe Balance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
    it { is_expected.to have_many(:outcomes).dependent(:destroy) }
    it { is_expected.to have_many(:incomes).dependent(:destroy) }
    it { is_expected.to have_many(:balance_payments).dependent(:destroy) }
    it { is_expected.to have_many(:payments).through(:balance_payments) }
  end
end
