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
      byebug
      return true if query_by_keyword?
      return true if query_by_dates?
      return true if query_by_keyword_and_dates?

      false
    end

    def query_by_keyword?
      params[:keyword]&.present? && empty_dates?
    end

    def query_by_dates?
      params[:keyword]&.empty? && !empty_dates?
    end

    def query_by_keyword_and_dates?
      params[:keyword]&.present? && !empty_dates?
    end

    def empty_dates?
      params[:start_date]&.empty? && params[:end_date]&.empty?
    end
  end
end