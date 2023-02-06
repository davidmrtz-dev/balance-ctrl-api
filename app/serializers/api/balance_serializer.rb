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
          total_balance
        ]
      )
    end
  end
end