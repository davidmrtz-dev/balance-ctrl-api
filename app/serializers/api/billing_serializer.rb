module Api
  class BillingSerializer
    def initialize(billing)
      @billing = billing
    end

    def self.json(billing)
      new(billing).json
    end

    def json
      @billing.serializable_hash(
        except: %i[
          user_id
          created_at
          updated_at
        ]
      )
    end
  end
end
