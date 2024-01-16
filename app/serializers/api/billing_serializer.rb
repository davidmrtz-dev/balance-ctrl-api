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
          discarded_at
          encrypted_credit_card_number
          encrypted_credit_card_number_iv
        ]
      )
    end
  end
end
