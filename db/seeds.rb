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
    payment_due_date: Time.zone.now
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

def create_income(balance)
  Income.create!(
    balance: balance,
    description: Faker::Commerce.product_name,
    amount: 65_000,
    transaction_date: Time.zone.now # Check when revisit incomes.
  )
end

def create_outcomes(balance)
  6.times do
    Outcome.create!(
      balance: balance,
      description: Faker::Commerce.product_name,
      transaction_date: Time.zone.now,
      amount: 1_500.00
    )
  end

  Outcome.create!(
    balance: balance,
    transaction_type: 'fixed',
    quotas: 2,
    description: Faker::Commerce.product_name,
    transaction_date: Time.zone.now,
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
  )
end

def attach_relations_to_outcomes(balance)
  cash = Billing.cash.first
  debit = Billing.debit.first
  credit = Billing.credit.first

  balance.outcomes.each do |outcome|
    # Attach category to transaction
    cat = Category.all.sample
    outcome.categories << cat

    # Attach billing to transaction
    billing = if outcome.transaction_type.eql?('current')
      [cash, debit].sample
    else
      credit
    end
    BillingTransaction.create!(
      billing: billing,
      related_transaction: outcome
    )

    next if outcome.transaction_type.eql?('current')
    # Relate payments with balance for fixed outcomes
    outcome.payments.each do |p|
      BalancePayment.create!(
        balance: balance,
        payment: p
      )
    end
  end

  balance.outcomes.fixed.first.payments.last.pending!
end

past_past_balance = create_balance(user, 'Past Past Balance', 'Past Past Balance Description', 11, 2023)
Timecop.freeze(Time.zone.now - 2.month) do
  create_income(past_past_balance)
  create_outcomes(past_past_balance)
  attach_relations_to_outcomes(past_past_balance)
end

past_balance = create_balance(user, 'Past Balance', 'Past Balance Description', 12, 2023)
Timecop.freeze(Time.zone.now - 1.month) do
  create_income(past_balance)
  create_outcomes(past_balance)
  attach_relations_to_outcomes(past_balance)
end

current_balance = create_balance(user, 'Current Balance', 'Current Balance Description', 1, 2024)
create_income(current_balance)
create_outcomes(current_balance)
attach_relations_to_outcomes(current_balance)
