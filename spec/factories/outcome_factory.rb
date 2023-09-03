class OutcomeFactory < BaseFactory
  def self.described_class
    Outcome
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      transaction_type: params.fetch(:transaction_type, :current),
      description: params.fetch(:description, Faker::Lorem.sentence(word_count: 6)),
      transaction_date: params.fetch(:transaction_date, Time.zone.today),
      amount: params.fetch(:amount, 1),
      quotas: params.fetch(:quotas, nil)
    }
  end
end
