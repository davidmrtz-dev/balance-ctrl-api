require 'faker'

class CategoryFactory
  def self.create(params = {})
    Category.create!(
      name: params.fetch(:name, Faker::Commerce.department(max: 1, fixed_amount: true))
    )
  end
end
