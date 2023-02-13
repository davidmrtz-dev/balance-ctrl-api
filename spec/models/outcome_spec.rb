require 'rails_helper'

RSpec.describe Outcome, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should have_db_column(:purchase_date).of_type(:datetime) }
  end

  describe 'validations' do
    it { should_not allow_value(:monthly).for(:frequency).on(:create) }
    it { should allow_value(DateTime.now).for(:purchase_date).on(:create) }

    describe 'when outcome transaction_type is :current' do
      it "should validate absence of 'quotas'" do
        outcome = Outcome.new(balance: balance, purchase_date: DateTime.now, quotas: 12)
        expect(outcome.valid?).to eq false
        expect(outcome.errors.full_messages.first).to eq("Quotas must be blank")
      end
    end

    describe 'when outcome transaction_type is :fixed' do
      it "should validate presence of 'quotas'" do
        outcome = Outcome.new(balance: balance, transaction_type: :fixed, purchase_date: DateTime.now)
        expect(outcome.valid?).to eq false
        expect(outcome.errors.full_messages.first).to eq("Quotas can't be blank")
      end
    end
  end

  describe '#update_balance_amount' do
    it 'should substract update balance current_amount' do
      Outcome.create(balance: balance, amount: 5_000, purchase_date: DateTime.now)

      expect(balance.reload.current_amount).to eq 5_000
    end
  end

  describe '#generate_payment' do
    it "should create one payment for 'current' outcome" do
      expect { Outcome.create(balance: balance, amount: 5_000, purchase_date: DateTime.now) }
        .to change { Payment.count }.by(1)

      expect(Payment.last.status).to eq 'applied'
    end
  end

  describe '#generate_payments' do
    it "'should create n 'quotas' payments for 'fixed' outcome" do
      expect { Outcome.create(balance: balance, amount: 12_000, transaction_type: :fixed, purchase_date: DateTime.now) }
    end
  end
end
