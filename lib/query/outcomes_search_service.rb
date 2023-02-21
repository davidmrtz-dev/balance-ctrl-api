module Query
  class OutcomesSearchService
    class << self
      def call(balance, word)
        Outcome.where(balance: balance).
          where('LOWER(description) LIKE :word', word: "%#{word.downcase}%")
      end
    end
  end
end