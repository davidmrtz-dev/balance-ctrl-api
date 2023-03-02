require 'rails_helper'

RSpec.describe Income, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  describe 'validations' do
    it { should_not allow_value(Time.zone.now).for(:transaction_date).on(:create) }
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

    context 'when income is :current' do
      it 'should not allow value of frequency' do
        income = Income.new(balance: balance, amount: 1_000, frequency: :monthly)

        expect(income.valid?).to be_falsey
      end
    end

    context 'when income is :fixed' do
      it 'should require value of frequency' do
        income = Income.new(balance: balance, amount: 1_000, frequency: :monthly, transaction_type: :fixed)

        expect(income.valid?).to be_truthy
      end
    end
  end

  context 'when income is :current' do
    let!(:income) do
      Income.create!(balance: balance, amount: 5_000)
    end

    describe '#after_create' do
      describe '#generate_payment' do
        it 'should create one payment' do
          expect { Income.create(balance: balance, amount: 5_000) }
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

    describe '#before_save' do
      it 'should add the diff from the amount when is negative' do
        expect(balance.current_amount).to eq 15_000
        income.update!(amount: 10_000)
        expect(balance.current_amount).to eq 20_000
      end

      it 'should substract the diff from the amount when is positive' do
        expect(balance.current_amount).to eq 15_000
        income.update!(amount: 1_000)
        expect(balance.current_amount).to eq 11_000
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
