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
    transaction_type: :fixed,
    description: Faker::Lorem.sentence(word_count: 4),
    frequency: :monthly
  )
end

40.times do
  Outcome.create!(
    balance: balance,
    transaction_type: :current,
    description: Faker::Lorem.sentence(word_count: 4),
    purchase_date: [Date.today - 2.days, Date.today - 1.day, Date.today].sample
  )
end
