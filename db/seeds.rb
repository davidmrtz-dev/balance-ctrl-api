return unless Rails.env.development? || Rails.env.staging?

# Create current user
user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
)

# Create payment methods
%i[debit credit cash].each do |type|
  Billing.create!(
    user: user,
    name: Faker::Finance.stock_market,
    billing_type: type,
    cycle_end_date: Time.zone.now,
    payment_due_date: Time.zone.now,
    credit_card_number: Faker::Finance.credit_card
  )
end

# Create categories
10.times do
  name = Faker::Commerce.department(max: 1, fixed_amount: true)

  next if Category.find_by(name: name)

  Category.create!(name: name)
end

def create_balance(user, title, description, month, year)
  Balance.create!(
    user: user,
    title: title,
    description: description,
    month: month,
    year: year
  )
end

def create_income(balance, description)
  Income.create!(
    balance: balance,
    description: description,
    amount: 50_000,
    transaction_date: Time.zone.now # Check when revisit incomes.
  )
end

def create_outcomes(balance)
  7.times do
    Outcome.create!(
      balance: balance,
      description: Faker::Commerce.product_name,
      transaction_date: Time.zone.now,
      amount: 1_000.00
    )
  end
end

def attach_relations_to_transactions(balance)
  cash = Billing.cash.first
  debit = Billing.debit.first
  credit = Billing.credit.first

  balance.outcomes.each do |outcome|
    # Attach category to transaction
    cat = Category.all.sample
    outcome.categories << cat

    # Relates billing with transaction
    billing = if outcome.transaction_type.eql?('current')
      [cash, debit].sample
    else
      credit
    end
    BillingTransaction.create!(
      billing: billing,
      related_transaction: outcome
    )
  end

  balance.incomes.each do |income|
    BillingTransaction.create!(
      billing: debit,
      related_transaction: income
    )
  end
end

def generate_title(date)
  months = %w[January February March April May June July August September October November December]

  "#{months[date.month - 1]} #{date.year}"
end

def create_fixed_outcome(balance)
  fixed_outcome = Outcome.create!(
    balance: balance,
    transaction_type: 'fixed',
    quotas: 3,
    description: Faker::Commerce.product_name,
    transaction_date: Time.zone.now,
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
  )

  fixed_outcome.payments
end

two_months_ago = 2.months.ago
past_past_balance = create_balance(user,  generate_title(two_months_ago), 'Description', 11, 2023)
f_p = create_fixed_outcome(past_past_balance)
Timecop.freeze(two_months_ago) do
  create_income(past_past_balance, generate_title(two_months_ago))
  create_outcomes(past_past_balance)
  attach_relations_to_transactions(past_past_balance)
  BalancePayment.create!(balance: past_past_balance, payment: f_p.first)
  f_p.first.applied!
end

one_month_ago = 1.month.ago
past_balance = create_balance(user, generate_title(one_month_ago), 'Description', 12, 2023)
Timecop.freeze(one_month_ago) do
  create_income(past_balance, generate_title(one_month_ago))
  create_outcomes(past_balance)
  attach_relations_to_transactions(past_balance)
  BalancePayment.create!(balance: past_balance, payment: f_p.second)
  f_p.second.applied!
end

current_balance = create_balance(user, generate_title(Time.zone.now), 'Description', 1, 2024)
create_income(current_balance, generate_title(Time.zone.now))
create_outcomes(current_balance)
attach_relations_to_transactions(current_balance)
BalancePayment.create!(balance: current_balance, payment: f_p.third)
f_p.third.pending!
