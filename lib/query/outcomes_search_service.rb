module Query
  class OutcomesSearchService
    attr_reader :balance, :params

    def initialize(balance, params)
      @balance = balance
      @params = params
    end

    def call
      raise_invalid_params unless valid_params

      if query_by_keyword?
        return Outcome.where(balance: balance).
          where('LOWER(description) LIKE :word', word: "%#{params[:keyword].downcase}%")
      elsif query_by_dates?
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])

        return Outcome.where(balance: balance).
          where(purchase_date: start_date..end_date)
      else
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])

        return Outcome.where(balance: balance).
          where('LOWER(description) LIKE :word', word: "%#{params[:keyword].downcase}%").
          where(purchase_date: start_date..end_date)
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