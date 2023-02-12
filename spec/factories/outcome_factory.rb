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
      purchase_date: params.fetch(:purchase_date, Date.today)
    }
  end
end