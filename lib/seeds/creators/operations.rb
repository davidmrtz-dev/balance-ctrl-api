module Seeds
  module Creators
    class Operations
      attr_reader :user, :balance, :date

      def initialize(user)
        @user = user
      end

      def create_balance
        @date = Time.zone.now

        @balance = Balance.create!(
          user: user,
          title: generate_title(date),
          description: Faker::Lorem.paragraph_by_chars(number: 128, supplemental: false),
          month: date.month,
          year: date.year
        )
      end

      def create_income(amount)
        i = Income.create!(
          balance: balance,
          description: generate_title(date),
          amount: amount,
          transaction_date: date.beginning_of_month + 8.hours
        )
        attach_billing(i)
      end

      def create_outcomes(quantity, type)
        quantity.times do
          o = create_outcome(type)
          attach_category(o)
          attach_billing(o)
        end
      end

      private

      def create_outcome(type)
        if type.eql?('current')
          create_current_outcome(generate_transaction_date)
        elsif type.eql?('fixed')
          create_fixed_outcome(generate_transaction_date)
        else
          raise 'Invalid outcome type'
        end
      end

      def attach_category(outcome)
        cat = Category.all.sample
        Categorization.create!(category: cat, transaction_record: outcome)
      end

      def attach_billing(transaction)
        BillingTransaction.create!(
          billing: assign_billing(transaction),
          related_transaction: transaction
        )
      end

      def assign_billing(transaction)
        case transaction.type
        when 'Income'
          Billing.debit.first
        when 'Outcome'
          billing_type =
            if transaction.transaction_type.eql?('current')
              %i[debit cash]
            else
              [:credit]
            end
          Billing.where(billing_type: billing_type).sample
        end
      end

      def create_current_outcome(transaction_date)
        Outcome.create!(
          balance: balance,
          description: Faker::Commerce.product_name,
          transaction_date: transaction_date,
          amount: Faker::Commerce.price(range: 500.00..1500.00, as_string: false)
        )
      end

      def create_fixed_outcome(transaction_date)
        Outcome.create!(
          balance: balance,
          description: Faker::Commerce.product_name,
          transaction_date: transaction_date,
          amount: Faker::Commerce.price(range: 2000.00..8000.00, as_string: false),
          transaction_type: :fixed,
          quotas: [6].sample # TODO: change to 3..24
        )
      end

      def generate_transaction_date
        date.change(
          day: (5..25).to_a.sample,
          hour: (0..23).to_a.sample
        ) +
          (1..60).to_a.sample.minutes +
          (1..60).to_a.sample.seconds
      end

      def generate_title(date)
        "#{date.strftime('%B')} #{date.year}"
      end
    end
  end
end
