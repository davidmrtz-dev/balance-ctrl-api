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
        include: {
          payments: {
            only: %i[
              amount
              status
            ]
          },
          billings: {
            except: %i[
              user_id
              created_at
              updated_at
            ]
          },
          categories: {
            only: %i[
              id
              name
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
