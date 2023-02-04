class FinanceActiveFactory < BaseFactory
  def self.described_class
    FinanceActive
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      income_frequency: params[:income_frequency] || :monthly,
      income_date: params.fetch(:income_date, Date.today.at_beginning_of_month),
      amount: params.fetch(:amount, 50_000.00)
    }
  end
end