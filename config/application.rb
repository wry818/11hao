require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Raisy
    class Application < Rails::Application
        # Settings in config/environments/* take precedence over those specified here.
        # Application configuration should go into files in config/initializers
        # -- all .rb files in that directory are automatically loaded.

        # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
        # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
        config.time_zone = 'UTC'

        # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
        # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
        # config.i18n.default_locale = :de
          
        config.google_analytics_id = ENV['GOOGLE_ANALYTICS_ID'] || ''
        
        config.action_mailer.default_url_options = { :host => ENV['ACTION_MAILER_DEFAULT_URL'] }
        config.action_mailer.asset_host = ENV['ACTION_MAILER_DEFAULT_URL']

        # Mailgun options
        config.action_mailer.smtp_settings = {
            :authentication => :plain,
            :address => "smtp.mailgun.org",
            :port => 587,
            :domain => ENV['MAILGUN_DOMAIN'],
            :user_name => ENV['MAILGUN_USERNAME'],
            :password => ENV['MAILGUN_PASSWORD']
        }

        config.default_user_image = 'default-user_kqyha1.png'
        config.default_facebook_image = 'raisy_pmuhdn.png'

        config.processing_fee_variable = 0.05
        config.processing_fee_fixed = 0

        config.admin_email = ENV['ADMIN_EMAIL']

        config.i18n.enforce_available_locales = false

        config.ent_url_base =  ENV['ENT_URL_BASE']
        config.ent_url_link_name =  ENV['ENT_URL_LINK_NAME']
        
        config.google_client_id = ENV['GOOGLE_CLIENT_ID']
        config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET']
        config.google_callback_url = ENV['GOOGLE_CALLBACK_URL']
        
        config.yahoo_client_id = ENV['YAHOO_CLIENT_ID']
        config.yahoo_client_secret = ENV['YAHOO_CLIENT_SECRET']
        config.yahoo_callback_url = ENV['YAHOO_CALLBACK_URL']
        
        config.mslive_client_id = ENV['MSLIVE_CLIENT_ID']
        config.mslive_client_secret = ENV['MSLIVE_CLIENT_SECRET']
        config.mslive_callback_url = ENV['MSLIVE_CALLBACK_URL']
        
        config.facebook_callback_url = ENV['FACEBOOK_CALLBACK_URL']        
    end
end
