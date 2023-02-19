return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
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
    description: Faker::Commerce.department(max: 1, fixed_amount: true),
    frequency: :monthly,
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
  )
end

13.times do
  Outcome.create!(
    balance: balance,
    description: Faker::Commerce.department(max: 1, fixed_amount: true),
    purchase_date: [
      Time.zone.now - 2.days, Time.zone.now - 1.day, Time.zone.now
    ].sample,
    amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
  )
end

8.times do
  Outcome.create!(
    balance: balance,
    transaction_type: 'fixed',
    quotas: [6, 12, 24].sample,
    description: Faker::Commerce.department(max: 1, fixed_amount: true),
    purchase_date: [
      Time.zone.now - 2.days, Time.zone.now - 1.day, Time.zone.now
    ].sample,
    amount: Faker::Number.decimal(l_digits: 5, r_digits: 2)
  )
end