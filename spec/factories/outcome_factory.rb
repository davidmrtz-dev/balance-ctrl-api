class OutcomeFactory < BaseFactory
  def self.described_class
    Outcome
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      title: params.fetch(:title, Faker::Lorem.sentence(word_count: 2)),
      description: params.fetch(:description, Faker::Lorem.sentence(word_count: 6)),
      obligation_type: params.fetch(:obligation_type, [:fixed, :current].sample),
      charge_date: params.fetch(:charge_date, Date.today),
      amount: params.fetch(:amount, 3_500.85)
    }
  end
end