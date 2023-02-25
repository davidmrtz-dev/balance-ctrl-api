module Api
  class IncomeSerializer
    def initialize(income)
      @income = income
    end

    def self.json(income)
      new(income).json
    end

    def json
      @income.serializable_hash(
        except: %i[
          balance_id
          created_at
          updated_at
        ]
      )
    end
  end
end