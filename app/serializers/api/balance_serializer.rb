module Api
  class BalanceSerializer
    def initialize(balance)
      @balance = balance
    end

    def self.json(balance)
      new(balance).json
    end

    def json
      @balance.serializable_hash(
        methods: %i[
          amount_incomes
          amount_paid
          amount_to_be_paid
          amount_for_payments
          comparison_percentage
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
