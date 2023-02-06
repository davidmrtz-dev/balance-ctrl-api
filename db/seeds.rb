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
    amount: 45000.00
  )

  FinanceObligation.create!(
    balance: balance,
    obligation_type: :fixed,
    status: :active,
    charge_date: Date.today.at_beginning_of_month,
    amount: 4567.84
  )
end
