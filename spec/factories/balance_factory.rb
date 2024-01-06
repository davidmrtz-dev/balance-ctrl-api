class BalanceFactory < BaseFactory
  def self.described_class
    Balance
  end

  def self.create_with_attachments(params)
    balance = create(params)
    create_actives(balance)
    create_passives(balance)
    balance
  end

  private

  def self.create_actives(balance)
    2.times do
      Income.create!(
        balance: balance,
        description: Faker::Lorem.sentence(word_count: 6),
        transaction_date: Time.zone.now,
        amount: 1
      )
    end
  end

  def self.create_passives(balance)
    4.times do
      Outcome.create!(
        balance: balance,
        description: Faker::Lorem.sentence(word_count: 6),
        transaction_date: Time.zone.now,
        amount: 1
      )
    end
    2.times do
      Outcome.create!(
        balance: balance,
        transaction_type: :fixed,
        description: Faker::Lorem.sentence(word_count: 6),
        transaction_date: Time.zone.now,
        quotas: 12,
        amount: 1
      )
    end
  end

  def options(params)
    {
      user: params.fetch(:user, nil),
      title: params.fetch(:title, 'Balance Title'),
      description: params.fetch(:description, 'Balance Description'),
      current_amount: params.fetch(:current_amount, 100_000),
      month: params.fetch(:month, Time.zone.now.month),
      year: params.fetch(:year, Time.zone.now.year)
    }
  end
end
