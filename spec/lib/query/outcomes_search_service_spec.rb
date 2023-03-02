require 'rails_helper'
require 'query/outcomes_search_service'

describe Query::OutcomesSearchService do
  let!(:today) { Date.today }
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let!(:outcome) do
    OutcomeFactory.create(balance: balance, transaction_date: today, description: 'Baby Clothes')
  end
  let!(:old_outcome) do
    OutcomeFactory.create(balance: balance, transaction_date: today.days_ago(2), description: 'Computer Desk')
  end

  describe 'when params are not valid' do
    it 'should raise an error' do
      expect do
        described_class.new(balance, {
          keyword: 'Baby',
          start_date: today.days_ago(2).to_s,
          end_date: ''
        }).call
      end.to raise_error(Errors::InvalidParameters)
    end
  end

  describe 'when params are valid' do
    describe 'when dates params are not provided but keyword' do
      it 'should return matching outcomes based on description' do
        result = described_class.new(balance, {
          keyword: 'Baby',
          start_date: '',
          end_date: ''
        }).call

        expect(result.count).to eq 1
        expect(result.first.id).to eq outcome.id
      end
    end

    describe 'when dates params are provided but not keyword' do
      it 'should return matching outcomes based on the dates range' do
        result = described_class.new(balance, {
          keyword: '',
          start_date: today.days_ago(2).to_s,
          end_date: today.days_ago(1).to_s
        }).call

        expect(result.count).to eq 1
        expect(result.first.id).to eq old_outcome.id
      end
    end

    describe 'when dates and keyword params are provided' do
      let!(:other_old_outcome) do
        OutcomeFactory.create(balance: balance, transaction_date: today.days_ago(3), description: 'Clothes')
      end

      it 'should return matching outcomes based on dates and keyword' do
        result = described_class.new(balance, {
          keyword: 'Clothes',
          start_date: today.days_ago(3).to_s,
          end_date: today.days_ago(2).to_s
        }).call

        expect(result.count).to eq 1
        expect(result.first.id).to eq other_old_outcome.id
      end
    end
  end
end