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
            payments: payments,
            billings: billings,
            categories: categories
          },
          except: %i[
            balance_id
            created_at
            updated_at
          ],
          methods: %i[
            status
          ]
        )
      end
    end

    private

    def payments
      {
        only: %i[
          id
          amount
          status
          folio
          paid_at
        ]
      }
    end

    def billings
      {
        except: %i[
          user_id
          created_at
          updated_at
        ]
      }
    end

    def categories
      {
        only: %i[
          id
          name
        ]
      }
    end
  end
end
