require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environments', __dir__)
# Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'database_cleaner/active_record'

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
Dir[Rails.root.join('lib/**/*.rb')].sort.each { |file| require file }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  Dir[File.join(__dir__, 'factories', '*.rb')].sort.each { |file| require file }
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ActionDispatch::TestProcess::FixtureFile, type: :request
  config.include ActionView::Helpers::NumberHelper

  ActiveJob::Base.queue_adapter = :test
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
