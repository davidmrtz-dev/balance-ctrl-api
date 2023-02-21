module Query
  class OutcomesSearchService
    class << self
      def call
        Outcome.where('description LIKE :name', name: "%#{name}%")
      end
    end
  end
end