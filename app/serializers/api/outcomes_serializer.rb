module Api
  class OutcomesSerializer
    def initialize(outcomes)
      @outcomes = outcomes
    end

    def self.json(outcomes)
      new(outcomes).json
    end

    def json
      @outcomes.map do |outcome|
        outcome.serializable_hash(
          include: {
            payments: {
              only: %i[
                amount
                status
              ]
            }
          },
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
