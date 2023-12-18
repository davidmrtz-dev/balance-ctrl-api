module Api
  class CategorySerializer
    def initialize(category)
      @category = category
    end

    def self.json(category)
      new(category).json
    end

    def json
      @category.serializable_hash(
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
