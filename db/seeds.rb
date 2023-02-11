return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password'
)

balance = Balance.find_or_create_by!(
  user: user,
  title: 'My Balance',
  description: 'My balance description',
  current_amount: 10_000
)

2.times do
  Income.create!(
    balance: balance,
    title: Faker::Lorem.sentence(word_count: 2),
    description: Faker::Lorem.sentence(word_count: 6),
    income_frequency: :monthly,
    income_type: :fixed,
    amount: Faker::Number.decimal(l_digits: 5, r_digits: 2)
  )
end

40.times do
  Outcome.create!(
    balance: balance,
    title: Faker::Lorem.sentence(word_count: 2),
    description: Faker::Lorem.sentence(word_count: 6),
    outcome_type: [:fixed, :current].sample,
    charge_date: [Date.today - 2.days, Date.today - 1.day, Date.today].sample,
    amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
  )
end
