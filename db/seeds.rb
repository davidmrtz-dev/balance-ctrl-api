return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password'
)

balance = Balance.create!(
  user: user,
  title: 'My Balance',
  description: 'My balance description',
  current_amount: 10_000
)

10.times do
  Income.create!(
    balance: balance,
    description: Faker::Lorem.sentence(word_count: 4),
    frequency: :monthly,
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
  )
end

40.times do
  Outcome.create!(
    balance: balance,
    description: Faker::Lorem.sentence(word_count: 4),
    purchase_date: [Date.today - 2.days, Date.today - 1.day, Date.today].sample,
    amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
  )
end
