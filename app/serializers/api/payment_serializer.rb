module Api
  class PaymentSerializer
    def initialize(payment)
      @payment = payment
    end

    def self.json(payment)
      new(payment).json
    end

    def json
      @payment.serializable_hash(
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
        ],
        methods: %i[payment_number]
      )
    end
  end
end
