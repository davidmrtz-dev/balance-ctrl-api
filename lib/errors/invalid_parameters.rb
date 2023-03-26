module Errors
  class InvalidParameters < StandardError
    def message
      'Parameters not valid'
    end
  end
end
