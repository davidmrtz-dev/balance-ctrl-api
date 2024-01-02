module Api
  class PaymentsSerializer
    def initialize(payments)
      @payments = payments
    end

    def self.json(payments)
      new(payments).json
    end

    def json
      @payments.map do |payment|
        payment.serializable_hash(
          include: {
            paymentable: {
              include: {
                categories: { only: %i[id name] },
                billings: { except: %i[user_id created_at updated_at] }
              },
              except: %i[balance_id created_at updated_at],
              methods: %i[status]
            }
          },
          except: %i[
            created_at
            updated_at
          ]
        )
      end
    end
  end
end
