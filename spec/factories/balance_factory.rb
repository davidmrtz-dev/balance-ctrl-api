class BalanceFactory < BaseFactory
  def self.described_class
    Balance
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