require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Raisy
    class Application < Rails::Application
        config.to_prepare do
          # Load application's model / class decorators
          Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
            Rails.configuration.cache_classes ? require(c) : load(c)
          end
        end
        
        # Add the fonts path
        config.assets.paths << Rails.root.join('app', 'assets', 'videos')
        
        # Precompile additional assets
        config.assets.precompile += %w( .mp4 )
        
        # Init ENV
        ENV['MAILGUN_DOMAIN'] = 'sandboxf6264257eeaf4129a4fb02ac4e7e987e.mailgun.org'
        ENV['MAILGUN_USERNAME'] = 'postmaster@sandboxf6264257eeaf4129a4fb02ac4e7e987e.mailgun.org'
        ENV['MAILGUN_PASSWORD'] = '7q7vmclgby93'
        
        config.url_host = "http://www.11haoonline.com"

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
        
        ENV['CLOUDINARY_URL']= 'cloudinary://195568989381351:wTcmdQ4UvTIjJy-2cVRykf-HiSo@jli'

        ENV['WEIXIN_APPID'] = 'wxc2251da36f59ced4'
        ENV['WEIXIN_APP_SECRET'] = 'cac0b5aec6aef1884138bb4970d5e54d'
        ENV['WEIXIN_API_KEY'] = '7KcRATv1Ino3mdopKaPGQQ7TtkNySuAm'
        ENV['WEIXIN_MCHID'] = '10019709'

        # show error page set
        # ENV['ERRORPAGESHOW'] = 'true'
        # config.error_page_ishow=true
        # Show full error reports and disable caching
        #defaults: true for development, false for production
        # config.action_controller.consider_all_requests_local = false

        config.exceptions_app = self.routes
        # ENV['WEIXIN_APPID'] = 'wxbd2427d5c32cbff6'
        # ENV['WEIXIN_APP_SECRET'] = '5fe619dff86284d07b9e301aca4bd2f3'
                
    end
end
