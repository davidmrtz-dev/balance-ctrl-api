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
          total_income
          total_expenses
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