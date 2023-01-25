class ApplicationController < ActionController::API
	# protect_from_forgery unless: -> { request.format.json? }
	include DeviseTokenAuth::Concerns::SetUserByToken
end
