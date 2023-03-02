require 'rails_helper'

RSpec.describe Outcome, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should have_db_column(:transaction_date).of_type(:date) }
  end

  describe 'validations' do
    it { should_not allow_value(:monthly).for(:frequency).on(:create) }
    it { should allow_value(Time.zone.now).for(:transaction_date).on(:create) }
    it { should_not allow_value(Time.zone.now + 1.day).for(:transaction_date).on(:create) }
    it { is_expected.to validate_numericality_of(:amount) }
    [
      1,
      50,
      1000
    ].each do |value|
      it { should allow_value(value).for(:amount).on(:create) }
      it { should allow_value(value).for(:amount).on(:update) }
    end

    describe 'when outcome is :current' do
      it "should validate absence of 'quotas'" do
        outcome = Outcome.new(balance: balance, transaction_date: Time.zone.now, quotas: 12, amount: 1)
        expect(outcome.valid?).to eq false
        expect(outcome.errors.full_messages.first).to eq("Quotas must be blank")
      end
    end

    describe 'when outcome is :fixed' do
      it "should validate presence of 'quotas'" do
        outcome = Outcome.new(balance: balance, transaction_type: :fixed, transaction_date: Time.zone.now, amount: 1)
        expect(outcome.valid?).to eq false
        expect(outcome.errors.full_messages.first).to eq("Quotas can't be blank")
      end
    end
  end


  describe 'when outcome is :current' do
    let!(:outcome) do
      Outcome.create!(balance: balance, amount: 5_000, transaction_date: Time.zone.now)
    end

    describe '#after_create' do
      describe '#generate_payment' do
        it 'should create one payment' do
          expect { Outcome.create!(balance: balance, amount: 5_000, transaction_date: Time.zone.now) }
            .to change { Payment.count }.by 1
        end

        it "should create one payment with state as 'applied'" do
          expect(outcome.payments.first.status).to eq 'applied'
        end
      end

      describe '#substract_balance_amount' do
        it 'should substract update balance current_amount' do
          expect(balance.current_amount).to eq 5_000
        end
      end
    end

    describe '#before_save' do
      it 'should add the diff from the amount when is positive' do
        expect(balance.current_amount).to eq 5_000
        outcome.update!(amount: 2_500)
        expect(balance.current_amount).to eq 7_500
      end

      it 'should substract the diff from the amount when is negative' do
        expect(balance.current_amount).to eq 5_000
        outcome.update!(amount: 7_500)
        expect(balance.current_amount).to eq 2_500
      end
    end

    describe '#before_destroy' do
      describe '#add_balance_amount' do
        it 'should return the amount to balance current_amount' do
          outcome.destroy!

          expect(balance.current_amount).to eq 10_000
        end
      end
    end
  end

  describe 'when outcome is :fixed' do
    describe '#after_create' do
      describe '#generate_payments' do
        let(:outcome) do
          OutcomeFactory.create(
            balance: balance,
            transaction_type: :fixed,
            amount: 12_000,
            quotas: 12
          )
        end

        it "'should create n 'quotas' payments" do
          expect do
            Outcome.create!(
              balance: balance,
              amount: 12_000,
              transaction_type: :fixed,
              transaction_date: Time.zone.now,
              quotas: 12
            )
          end.to change { Payment.count }.by 12
        end

        it "should create payments with state as 'pending'" do
          expect(outcome.payments.pluck(:status).uniq.first).to eq 'pending'
        end

        it 'should create payment with amount as outcome.amount / outcome.quotas' do
          expect(outcome.payments.last.amount).to eq outcome.amount / outcome.quotas
        end
      end
    end
  end
end
