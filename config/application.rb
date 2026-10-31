require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Shoppe
  class Application < Rails::Application
    config.generators.helper = false
    config.load_defaults 8.1
    config.to_prepare { Devise::Mailer.layout 'email' }
    # config.active_record.raise_in_transactional_callbacks = true
  end
end
