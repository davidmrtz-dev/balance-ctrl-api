require 'rails_helper'
require 'query/outcomes_search_service'

describe Query::OutcomesSearchService do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let!(:outcome) { OutcomeFactory.create(balance: balance, purchase_date: Time.zone.today, description: 'Baby Clothes') }
  let!(:other_outcome) { OutcomeFactory.create(balance: balance, purchase_date: Time.zone.today, description: 'Computer Desk') }

  it 'return and array of matching outcomes' do
    result = described_class.call(balance, 'Baby')

    expect(result.count).to eq 1
    expect(result.first.id).to eq outcome.id
  end
end