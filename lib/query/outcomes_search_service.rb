module Query
  class OutcomesSearchService
    attr_reader :balance, :params

    def initialize(balance, params)
      @balance = balance
      @params = params
    end

    def call
      Outcome.where(balance: balance).
        where('LOWER(description) LIKE :word', word: "%#{params[:keyword].downcase}%")
    end

    private

    def raise_invalid_params
      raise Errors::InvalidParameters
    end

    def valid_params
      return true if params[:keyword]&.present? && param
    end
  end
end