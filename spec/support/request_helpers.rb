# frozen_string_literal: true

module RequestHelpers
  def parsed_response
    body = JSON.parse(response.body)

    if body.instance_of?(Hash)
      body.with_indifferent_access
    elsif body.instance_of?(Array)
      body
    end
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
