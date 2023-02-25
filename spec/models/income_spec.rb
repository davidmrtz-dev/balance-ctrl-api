require 'rails_helper'

RSpec.describe Income, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  describe 'validations' do
    it { should allow_value(:monthly).for(:frequency).on(:create) }
    it { should_not allow_value(Time.zone.now).for(:purchase_date).on(:create) }
    it { should_not allow_value(12).for(:quotas).on(:create) }
    it { is_expected.to validate_numericality_of(:amount) }
    [
      1,
      50,
      1000
    ].each do |value|
      it { should allow_value(value).for(:amount).on(:create) }
      it { should allow_value(value).for(:amount).on(:update) }
    end
  end

  describe 'when income is :current' do
    let!(:income) do
      Income.create!(balance: balance, amount: 5_000, frequency: :monthly)
    end

    describe '#after_create' do
      describe '#generate_payment' do
        it 'should create one payment' do
          expect { Income.create(balance: balance, amount: 5_000, frequency: :monthly) }
            .to change { Payment.count }.by(1)
        end

        it "should create one payment with state as 'applied'" do
          expect(income.payments.first.status).to eq 'applied'
        end
      end

      describe '#add_balance_amount' do
        it 'should sum the amount to balance current_amount' do
          expect(balance.current_amount).to eq 15_000
        end
      end
    end

    describe '#before_destroy' do
      describe '#substract_balance_amount' do
        it 'should return the amount to balance current_amount' do
          income.destroy!

          expect(balance.current_amount).to eq 10_000
        end
      end
    end
  end
end
