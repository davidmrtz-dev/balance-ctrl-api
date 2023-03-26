module Errors
  class Type
    class << self
      def capture_exception(exception)
        case exception
        when ActiveRecord::RecordInvalid, ActiveModel::StrictValidationFailed
          yield I18n.t('errors.invalid_data'), :unprocessable_entity
        when ActionController::ParameterMissing
          yield I18n.t('errors.parameter_missing'), :unprocessable_entity
        when ActiveRecord::RecordNotFound
          yield I18n.t('errors.record_not_found'), :not_found
        when ActiveRecord::RecordNotUnique
          yield I18n.t('errors.invalid_data'), :conflict
        when Errors::InvalidParameters
          yield exception.message, :unprocessable_entity
        else
          yield I18n.t('errors.internal_server_error'), :internal_server_error
        end
      end
    end
  end
end