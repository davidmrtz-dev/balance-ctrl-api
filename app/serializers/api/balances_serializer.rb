module Api
  class BalancesSerializer
    def initialize(balances)
      @balances = balances
    end

    def self.json(balances)
      new(balances).json
    end

    def json
      @balances.map do |balance|
        balance.serializable_hash(
          methods: %i[
            amount_incomes
            amount_outcomes
            amount_paid
            amount_to_be_paid
            amount_for_payments
            is_current?
          ],
          except: %i[
            user_id
            created_at
            updated_at
          ]
        )
      end
    end
  end
end
