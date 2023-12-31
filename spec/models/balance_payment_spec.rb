require 'rails_helper'

RSpec.describe BalancePayment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { is_expected.to belong_to(:payment) }
  end
end
