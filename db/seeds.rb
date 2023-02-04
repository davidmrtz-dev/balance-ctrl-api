# return unless Rails.env.development? || Rails.env.staging?

# user = User.find_or_create_by!(
#   email: 'user@example.com',
#   password: 'password',
#   password_confirmation: 'password'
# )

# balance = Balance.find_or_create_by!(user: user)

# 2.times.do |num|
#   FinanceActive.create!(balance: balance)
# end
