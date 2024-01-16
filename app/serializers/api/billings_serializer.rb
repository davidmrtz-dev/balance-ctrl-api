module Api
  class BillingsSerializer
    def initialize(billings)
      @billings = billings
    end

    def self.json(billings)
      new(billings).json
    end

    def json
      @billings.map do |billing|
        billing.serializable_hash(
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
end
