class ApiController < ActionController::API
	include DeviseTokenAuth::Concerns::SetUserByToken
end
