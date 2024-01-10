require_relative 'boot'
require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'

Bundler.require(*Rails.groups)

module BalanceCtrlEnhancedApi
  class Application < Rails::Application
    config.load_defaults 6.1
    config.api_only = true
    config.autoloader = :zeitwerk
    config.eager_load_paths << Rails.root.join('lib')
    config.time_zone = 'Mexico/General'
    config.generators do |g|
      g.test_framework :rspec
      g.view_specs false
      g.helper_specs false
      g.routing_specs false
      g.request_specs false
      g.controller_specs true
      g.assets false
      g.helper false
      g.view false
    end
  end
end
