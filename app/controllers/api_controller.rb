class ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ErrorHandler
end
