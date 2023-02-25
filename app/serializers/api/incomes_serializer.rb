module Api
  class IncomesSerializer
    def initialize(incomes)
      @incomes = incomes
    end

    def self.json(incomes)
      new(incomes).json
    end

    def json
      @incomes.map do |income|
        income.serializable_hash(
          except: %i[
            balance_id
            created_at
            updated_at
          ]
        )
      end
    end
  end
end