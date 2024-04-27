module Seeds
  class AttacherManager
    attr_reader :user

    def initialize(user)
      @user = user
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def attach_payments
      balances = user.balances.reverse
      fixed_outcomes = balances.map(&:outcomes).flatten.select(&:fixed?)

      fixed_outcomes.each do |outcome|
        bal_ids = get_balances_from(balances.pluck(:id), outcome.balance_id)

        payments = outcome.payments.first(bal_ids.size)

        all_appplied = bal_ids.size > payments.size

        payments.each_with_index do |payment, index|
          BalancePayment.create!(balance_id: bal_ids[index], payment_id: payment.id)
          payment_status = if all_appplied
                             :applied
                           else
                             (index == payments.size - 1 ? :pending : :applied)
                           end

          if payment_status.eql?(:applied)
            payment.update!(paid_at: payment.paymentable.transaction_date, status: payment_status)
          else
            payment.update!(status: payment_status)
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def get_balances_from(balance_ids, start_id)
      start_index = balance_ids.index(start_id)

      return [] unless start_index

      balance_ids[start_index..]
    end
  end
end
