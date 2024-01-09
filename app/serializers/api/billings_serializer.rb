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
          ]
        )
      end
    end
  end
end
