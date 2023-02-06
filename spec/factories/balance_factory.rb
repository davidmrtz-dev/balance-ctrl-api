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
      FinanceActive.create!(
        balance: balance,
        title: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.sentence(word_count: 6),
        income_frequency: :monthly,
        active_type: :fixed,
        amount: Faker::Number.decimal(l_digits: 5, r_digits: 2)
      )
    end
  end

  def self.create_passives(balance)
    4.times do
      FinanceObligation.create!(
        balance: balance,
        title: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.sentence(word_count: 6),
        obligation_type: :fixed,
        charge_date: [Date.today - 2.days, Date.today - 1.day, Date.today].sample,
        amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
      )
    end
    2.times do
      FinanceObligation.create!(
        balance: balance,
        title: Faker::Lorem.sentence(word_count: 2),
        description: Faker::Lorem.sentence(word_count: 6),
        obligation_type: :current,
        charge_date: [Date.today - 2.days, Date.today - 1.day, Date.today].sample,
        amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
      )
    end
  end

  def options(params)
    {
      user: params.fetch(:user, nil),
      title: params.fetch(:title, 'Balance Title'),
      description: params.fetch(:description, 'Balance Description')
    }
  end
end