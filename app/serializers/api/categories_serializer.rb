module Api
  class CategoriesSerializer
    def initialize(categories)
      @categories = categories
    end

    def self.json(categories)
      new(categories).json
    end

    def json
      @categories.map do |category|
        category.serializable_hash(
          except: %i[
            created_at
            updated_at
            discarded_at
          ],
          methods: %i[
            discarded?
          ]
        )
      end
    end
  end
end
