module Query
  class OutcomesSearchService
    class << self
      def call(balance, params)
        Outcome.where(balance: balance).
          where('LOWER(description) LIKE :word', word: "%#{params[:keyword].downcase}%")
      end
    end
  end
end