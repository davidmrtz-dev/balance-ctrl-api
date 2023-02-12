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
        income_type: :fixed,
        title: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.sentence(word_count: 6),
        income_frequency: :monthly
      )
    end
  end

  def self.create_passives(balance)
    4.times do
      Outcome.create!(
        balance: balance,
        outcome_type: :current,
        title: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.sentence(word_count: 6),
        purchase_date: [Date.today - 2.days, Date.today - 1.day, Date.today].sample
      )
    end
    2.times do
      Outcome.create!(
        balance: balance,
        outcome_type: :fixed,
        title: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.sentence(word_count: 6),
        purchase_date: [Date.today - 2.days, Date.today - 1.day, Date.today].sample
      )
    end
  end

  def options(params)
    {
      user: params.fetch(:user, nil),
      title: params.fetch(:title, 'Balance Title'),
      description: params.fetch(:description, 'Balance Description'),
      current_amount: params.fetch(:current_amount, 10_000)
    }
  end
end