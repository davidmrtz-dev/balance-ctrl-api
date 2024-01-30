module Seeds
  module Creators
    class Misc
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def create_billing(type, cycle_end_day = nil, payment_due_day = nil)
        Billing.create!(
          user: user,
          name: Faker::Finance.stock_market,
          billing_type: type,
          cycle_end_date: cycle_end_date(cycle_end_day),
          payment_due_date: cycle_end_date(payment_due_day),
          credit_card_number: [:cash].include?(type) ? nil : Faker::Finance.credit_card
        )
      end

      def create_categories
        15.times do
          name = Faker::Commerce.department(max: 1, fixed_amount: true)

          Category.find_or_create_by!(name: name)
        end
      end

      private

      def cycle_end_date(day)
        day.nil? ? nil : Time.zone.now.change(day: day)
      end
    end
  end
end
