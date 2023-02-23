require 'rails_helper'
require 'query/outcomes_search_service'

describe Query::OutcomesSearchService do
  let!(:today) { Date.today }
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let!(:outcome) { OutcomeFactory.create(balance: balance, purchase_date: today, description: 'Baby Clothes') }
  let!(:other_outcome) { OutcomeFactory.create(balance: balance, purchase_date: today.days_ago(2), description: 'Computer Desk') }

  xdescribe 'when params are not valid' do
    it 'should raise an error' do
      expect do
        described_class.call(balance, { start_date: today.days_ago(2) })
      end.to raise_error
    end
  end

  describe 'when params are valid' do
    describe 'when dates params are not provided but keyword' do
      it 'should return matching outcomes based on description' do
        result = described_class.call(balance, { keyword: 'Baby' })

        expect(result.count).to eq 1
        expect(result.first.id).to eq outcome.id
      end
    end

    xdescribe 'when dates params are provided but not keyword' do
      it 'should return matching outcomes based on the dates range' do
      end
    end

    xdescribe 'when dates and keyword params are provided' do
      it 'should return matching outcomes based on dates and keyword' do
      end
    end
  end
end