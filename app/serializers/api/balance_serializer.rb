module Api
  class BalanceSerializer
    def initialize(balance)
      @balance = balance
    end

    def self.json(balance)
      new(balance).json
    end

    def json
      @balance.as_json
    end
  end
end