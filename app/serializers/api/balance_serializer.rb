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
        include: [
          :finance_actives,
          :finance_obligations
        ]
      )
    end
  end
end