module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |exception|
      handle_exception(exception)
    end
  end

  private

  def handle_exception(exception)
    general_logger(exception)

    Errors::Type.capture_exception(exception) { |message, status| renderer(message, status) }
  end

  def general_logger(exception)
    logger.error "Error Class: #{exception.class}"
    logger.error "Error Message: #{exception.message}"
  end

  def renderer(message, status)
    render json: { message: message }, status: status
  end
end
