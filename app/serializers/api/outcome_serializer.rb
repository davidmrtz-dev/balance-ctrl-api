module Api
  class OutcomeSerializer
    def initialize(outcome)
      @outcome = outcome
    end

    def self.json(outcome)
      new(outcome).json
    end

    def json
      @outcome.serializable_hash(
        except: %i[
          balance_id
          created_at
          updated_at
        ]
      )
    end
  end
end
