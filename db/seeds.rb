return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password'
)

balance = Balance.find_or_create_by!(user: user)

2.times do
  FinanceActive.create!(
    balance: balance,
    income_frequency: :monthly,
    active_type: :fixed,
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
  )
end

40.times do
  FinanceObligation.create!(
    balance: balance,
    obligation_type: [:fixed, :current].sample,
    status: :active,
    charge_date: [Date.today - 2.days, Date.yesterday, Date.today].sample,
    amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
  )
end
