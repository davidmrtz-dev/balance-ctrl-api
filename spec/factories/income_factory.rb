class IncomeFactory < BaseFactory
  def self.described_class
    Income
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      transaction_type: params.fetch(:transaction_type, :current),
      description: params.fetch(:description, Faker::Lorem.sentence(word_count: 6)),
      frequency: params.fetch(:frequency, :monthly),
      amount: params.fetch(:amount, 1)
    }
  end
end