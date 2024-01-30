module Seeds
  class CreatorManager
    include Seeds::Creators

    attr_reader :misc, :operations

    def initialize(user)
      @misc = Misc.new(user)
      @operations = Operations.new(user)
    end

    def create_billings_and_categories
      misc.create_billing(:debit)
      misc.create_billing(:credit, 21, 15)
      misc.create_billing(:credit, 2, 28)
      misc.create_billing(:cash)
      misc.create_categories
    end

    def create_operations_for(date:, income_amount:, current_outcomes: 7, fixed_outcomes: 2)
      Timecop.freeze(date) do
        operations.create_balance
        operations.create_income(income_amount)
        operations.create_outcomes(current_outcomes, 'current')
        operations.create_outcomes(fixed_outcomes, 'fixed')
      end
    end
  end
end
