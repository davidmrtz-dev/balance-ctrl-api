module Query
  class OutcomesSearchService
    attr_reader :user, :params

    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      raise_invalid_params unless valid_params

      ActiveRecord::Base.transaction do
        if query_by_keyword?
          Outcome
            .with_balance_and_user
            .from_user(user)
            .where('LOWER(transactions.description) LIKE :word', word: "%#{params[:keyword].downcase}%")
        elsif query_by_dates?
          start_date = DateTime.parse(params[:start_date])
          end_date = DateTime.parse(params[:end_date])

          Outcome
            .with_balance_and_user
            .from_user(user)
            .where(transaction_date: start_date..end_date)
        else
          start_date = DateTime.parse(params[:start_date])
          end_date = DateTime.parse(params[:end_date])

          Outcome
            .with_balance_and_user
            .from_user(user)
            .where('LOWER(transactions.description) LIKE :word', word: "%#{params[:keyword].downcase}%")
            .where(transaction_date: start_date..end_date)
        end
      end
    end

    private

    def raise_invalid_params
      raise Errors::InvalidParameters
    end

    def valid_params
      return true if query_by_keyword? ||
                     query_by_dates? || query_by_key_and_dates?

      false
    end

    def query_by_keyword?
      with_keyword? && !with_start_date? && !with_end_date?
    end

    def query_by_dates?
      !with_keyword? && with_start_date? && with_end_date?
    end

    def query_by_key_and_dates?
      with_keyword? && with_start_date? && with_end_date?
    end

    def with_keyword?
      params[:keyword]&.present?
    end

    def with_start_date?
      params[:start_date]&.present?
    end

    def with_end_date?
      params[:end_date]&.present?
    end
  end
end
