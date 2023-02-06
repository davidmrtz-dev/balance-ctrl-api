class FinanceObligationFactory < BaseFactory
  def self.described_class
    FinanceObligation
  end

  private

  def options(params)
    {
      balance: params.fetch(:balance, nil),
      obligation_type: params.fetch(:obligation_type, [:fixed, :current].sample),
      charge_date: params.fetch(:charge_date, Date.today),
      amount: params.fetch(:amount, 3_500.85)
    }
  end
end