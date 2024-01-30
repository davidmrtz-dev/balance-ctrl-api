return unless Rails.env.development? || Rails.env.staging?

user = User.first || User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
)

creator = Seeds::CreatorManager.new(user)

creator.create_billings_and_categories
creator.create_operations_for(
  date: 3.months.ago,
  income_amount: 55_000,
  current_outcomes: 0,
  fixed_outcomes: 1
)
creator.create_operations_for(
  date: 2.months.ago,
  income_amount: 55_000,
  current_outcomes: 0,
  fixed_outcomes: 1
)
creator.create_operations_for(
  date: 1.months.ago,
  income_amount: 55_000,
  current_outcomes: 0,
  fixed_outcomes: 0
)
creator.create_operations_for(
  date: Time.zone.now,
  income_amount: 55_000,
  current_outcomes: 0,
  fixed_outcomes: 0
)

attacher = Seeds::AttacherManager.new(user)

attacher.attach_payments
