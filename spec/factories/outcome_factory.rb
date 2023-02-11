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
      charge_date: params.fetch(:charge_date, Date.today)
    }
  end
end