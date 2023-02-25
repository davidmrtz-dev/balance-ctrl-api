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
        frequency: :monthly,
        amount: 1
      )
    end
  end

  def self.create_passives(balance)
    4.times do
      Outcome.create!(
        balance: balance,
        description: Faker::Lorem.sentence(word_count: 6),
        purchase_date: [Time.zone.now - 2.days, Time.zone.now - 1.day, Time.zone.now].sample,
        amount: 1
      )
    end
    2.times do
      Outcome.create!(
        balance: balance,
        transaction_type: :fixed,
        description: Faker::Lorem.sentence(word_count: 6),
        purchase_date: [Time.zone.now - 2.days, Time.zone.now - 1.day, Time.zone.now].sample,
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
      current_amount: params.fetch(:current_amount, 100_000)
    }
  end
end