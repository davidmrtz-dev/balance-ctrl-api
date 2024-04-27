return unless Rails.env.development? || Rails.env.staging?

user = User.first || User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
)

creator = Seeds::CreatorManager.new(user)

creator.create_billings_and_categories

months = 7
months_ago = months - 1
months.times do |i|
  creator.create_operations_for(
    date: months_ago.months.ago.beginning_of_month,
    income_amount: (35_000..75_000).to_a.sample,
    current_outcomes: (12..25).to_a.sample,
    fixed_outcomes: (5..10).to_a.sample
  )

  puts "=====> Created transactions for #{months_ago.months.ago.beginning_of_month.strftime('%B') + ' ' + months_ago.months.ago.year.to_s}"
  months_ago -= 1
end

attacher = Seeds::AttacherManager.new(user)

attacher.attach_payments
