class BalanceFactory < BaseFactory
  def self.described_class
    Balance
  end

  def self.create_with_attachments(params)
    balance = create(params)
    2.times do
      FinanceActive.create!(
        balance: balance,
        income_frequency: :monthly,
        income_date: Date.today.at_beginning_of_month,
        amount: 45000.00
      )
    end
    4.times do
      FinanceObligation.create!(
        balance: balance,
        obligation_type: :fixed,
        status: :active,
        charge_date: Date.today.at_beginning_of_month,
        amount: 4567.84
      )
    end
    balance
  end

  private

  def options(params)
    {
      user: params.fetch(:user, nil),
      title: params.fetch(:title, 'Balance Title'),
      description: params.fetch(:description, 'Balance Description')
    }
  end
end