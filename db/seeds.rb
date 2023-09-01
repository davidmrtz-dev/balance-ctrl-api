return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
)

billing = Billing.create!(
  user: user,
  name: 'My Billing',
  state_date: 2.days.ago,
  card_type: :credit
)

balance = Balance.create!(
  user: user,
  title: 'My Balance',
  description: 'My balance description'
)

10.times do
  name = Faker::Commerce.department(max: 1, fixed_amount: true)

  next if Category.find_by(name: name)

  Category.create!(name: name)
end

10.times do
  Income.create!(
    balance: balance,
    description: Faker::Commerce.department(max: 1, fixed_amount: true),
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2),
    transaction_date: Time.zone.now
  )
end

5.times do
  Outcome.create!(
    balance: balance,
    description: Faker::Commerce.department(max: 1, fixed_amount: true),
    transaction_date: Time.zone.now,
    amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
  )
end

Outcome.create!(
  balance: balance,
  transaction_type: 'fixed',
  quotas: 6,
  description: Faker::Commerce.department(max: 2, fixed_amount: true),
  transaction_date: Time.zone.now,
  amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
)

Outcome.all.each do |t|
  cat = Category.all.sample

  t.categories << cat

  BillingTransaction.create!(
    billing: billing,
    related_transaction: t
  )
end

Outcome.fixed_types.first.payments.first.update!(status: Payment.statuses.keys.second)
