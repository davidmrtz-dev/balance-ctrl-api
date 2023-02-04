class FinanceObligationFactory < BaseFactory
  def self.described_class
    FinanceObligation
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      income_frequency: params[:obligation_type] || :fixed,
      income_date: params[:status] || :active,
      charge_date: params.fetch(:charge_date, Date.today),
      amount: params.fetch(:amount, 3_500.85)
    }
  end
end