require 'faker'

class UserFactory
  def self.create(params = {})
    User.create!(
      email: params.fetch(:email, Faker::Internet.email),
      password: params[:password]
    )
  end
end