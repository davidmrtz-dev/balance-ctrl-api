module Seeds
  class AttacherManager
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def attach_payments
      balances = user.balances.reverse
      fixed_outcomes = balances.map(&:outcomes).flatten.select(&:fixed?)

      fixed_outcomes.each do |outcome|
        bal_ids = get_balances_from(balances.pluck(:id), outcome.balance_id)
        payments = outcome.payments.first(bal_ids.size)

        create_balance_payments(payments, bal_ids)
      end
    end

    private

    def create_balance_payments(payments, bal_ids)
      payments.each_with_index do |payment, index|
        attach_and_update(payment, bal_ids[index], index, payments.size)
      end
    end

    def attach_and_update(payment, bal_id, idx, size)
      BalancePayment.create!(
        balance_id: bal_id,
        payment_id: payment.id
      )

      if idx.eql?(size - 1)
        payment.pending!
      else
        payment.applied!
      end
    end

    def get_balances_from(balance_ids, start_id)
      start_index = balance_ids.index(start_id)

      return [] unless start_index

      balance_ids[start_index..]
    end
  end
end
