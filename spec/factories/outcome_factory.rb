class OutcomeFactory < BaseFactory
  def self.described_class
    Outcome
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      outcome_type: params.fetch(:outcome_type, [:current, :fixed].sample),
      title: params.fetch(:title, Faker::Lorem.sentence(word_count: 2)),
      description: params.fetch(:description, Faker::Lorem.sentence(word_count: 6)),
      purchase_date: params.fetch(:purchase_date, Date.today)
    }
  end
end