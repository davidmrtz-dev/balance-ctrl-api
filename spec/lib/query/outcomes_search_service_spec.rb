require 'rails_helper'
require 'query/outcomes_search_service'

describe Query::OutcomesSearchService do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let!(:outcome) do
    OutcomeFactory.create(balance: balance, transaction_date: Time.zone.now, description: 'Baby Clothes')
  end

  describe 'when params are not valid' do
    it 'should raise an error' do
      expect do
        described_class.new(user, {
          keyword: 'Baby',
          start_date: 1.day.ago.to_s,
          end_date: ''
        }).call
      end.to raise_error(Errors::InvalidParameters)
    end
  end

  describe 'when params are valid' do
    describe 'when dates params are not provided but keyword' do
      it 'should return matching outcomes based on description' do
        result = described_class.new(user, {
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
        result = described_class.new(user, {
          keyword: '',
          start_date: 1.day.ago.to_s,
          end_date: 1.day.from_now.to_s
        }).call

        expect(result.count).to eq 1
        expect(result.first.id).to eq outcome.id
      end
    end

    describe 'when dates and keyword params are provided' do
      it 'should return matching outcomes based on dates and keyword' do
        result = described_class.new(user, {
          keyword: 'Clothes',
          start_date: 1.day.ago.to_s,
          end_date: 1.day.from_now.to_s
        }).call

        expect(result.count).to eq 1
        expect(result.first.id).to eq outcome.id
      end
    end
  end
end
