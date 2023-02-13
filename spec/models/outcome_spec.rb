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
    it { should allow_value(Time.zone.now).for(:purchase_date).on(:create) }
    it { should_not allow_value(Time.zone.now + 1.day).for(:purchase_date).on(:create) }

    describe 'when outcome transaction_type is :current' do
      it "should validate absence of 'quotas'" do
        outcome = Outcome.new(balance: balance, purchase_date: Time.zone.now, quotas: 12)
        expect(outcome.valid?).to eq false
        expect(outcome.errors.full_messages.first).to eq("Quotas must be blank")
      end
    end

    describe 'when outcome transaction_type is :fixed' do
      it "should validate presence of 'quotas'" do
        outcome = Outcome.new(balance: balance, transaction_type: :fixed, purchase_date: Time.zone.now)
        expect(outcome.valid?).to eq false
        expect(outcome.errors.full_messages.first).to eq("Quotas can't be blank")
      end
    end
  end


  describe 'when transaction_type is :current' do
    describe '#after_create' do
      let!(:outcome) do
        Outcome.create!(balance: balance, amount: 5_000, purchase_date: Time.zone.now)
      end

      describe '#update_balance_amount' do
        it 'should substract update balance current_amount' do
          expect(balance.current_amount).to eq 5_000
        end
      end

      describe '#generate_payment' do
        it 'should create one payment' do
          expect { Outcome.create!(balance: balance, amount: 5_000, purchase_date: Time.zone.now) }
            .to change { Payment.count }.by 1
        end

        it "should create one payment with state as 'applied'" do
          expect(outcome.payments.first.status).to eq 'applied'
        end
      end
    end

    xdescribe '#after_destroy' do
      describe '#update_balance_amount' do
        it 'should return back amount to balance current_amount' do
          Outcome.create!(balance: balance, amount: 5_000, purchase_date: Time.zone.now)

          expect(balance.reload.current_amount).to eq 5_000
        end
      end
    end
  end

  describe 'when transaction_type is :fixed' do
    describe '#after_create' do
      describe '#generate_payments' do
        let(:outcome) do
          OutcomeFactory.create(
            balance: balance,
            amount: 12_000,
            transaction_type: :fixed,
            purchase_date: Time.zone.now,
            quotas: 12
          )
        end

        it "'should create n 'quotas' payments" do
          expect do
            Outcome.create!(
              balance: balance,
              amount: 12_000,
              transaction_type: :fixed,
              purchase_date: Time.zone.now,
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
