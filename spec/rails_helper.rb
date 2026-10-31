ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
# DATABASE_URL (or .env) overrides database.yml, and the suite truncates every table
test_db = ActiveRecord::Base.connection_db_config.database
abort("Refusing to run the tests against #{test_db}: its name must end in _test") unless test_db.to_s.end_with?('_test')
DatabaseCleaner.allow_remote_database_url = true
require 'spec_helper'
require 'rspec/rails'


ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.use_transactional_fixtures = false

  config.before(:suite) do
    Rails.application.reload_routes_unless_loaded
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Devise::Test::IntegrationHelpers, type: :request

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
