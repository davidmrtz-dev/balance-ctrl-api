return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
)

5.times.each do |i|
  Billing.create!(
    user: user,
    name: "Billing #{i + 1}",
    state_date: [
      Time.zone.now,
      2.days.ago,
      4.days.from_now,
      5.days.ago
    ].sample,
    billing_type: :credit
  )
end

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
    description: Faker::Commerce.product_name,
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2),
    transaction_date: Time.zone.now
  )
end

5.times do
  Outcome.create!(
    balance: balance,
    description: Faker::Commerce.product_name,
    transaction_date: Time.zone.now,
    amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
  )
end

Outcome.create!(
  balance: balance,
  transaction_type: 'fixed',
  quotas: 6,
  description: Faker::Commerce.product_name,
  transaction_date: Time.zone.now,
  amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
)

Outcome.all.each do |t|
  cat = Category.all.sample

  t.categories << cat

  BillingTransaction.create!(
    billing: Billing.all.sample,
    related_transaction: t
  )
end

Outcome.fixed.first.payments.first.update!(status: Payment.statuses.keys.second)
