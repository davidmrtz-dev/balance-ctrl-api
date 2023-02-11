class IncomeFactory < BaseFactory
  def self.described_class
    Income
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      title: params.fetch(:title, Faker::Lorem.sentence(word_count: 2)),
      description: params.fetch(:description, Faker::Lorem.sentence(word_count: 6)),
      income_frequency: params[:income_frequency] || :monthly,
      income_type: params.fetch(:income_date, [:fixed, :current].sample),
      amount: params.fetch(:amount, Faker::Number.decimal(l_digits: 5, r_digits: 2))
    }
  end
end