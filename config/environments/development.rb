Raisy::Application.configure do
    # Settings specified here will take precedence over those in config/application.rb.

    config.facebook_app_id = ENV['FACEBOOK_APP_ID_DEV']
    config.facebook_app_secret = ENV['FACEBOOK_APP_SECRET_DEV']
    config.twitter_app_id = ENV['TWITTER_APP_ID']
    config.twitter_app_secret = ENV['TWITTER_APP_SECRET']
    
    config.braintree_client_side_encyption_key = ENV['BRAINTREE_CLIENT_SIDE_ENCRYPTION_KEY_DEV']
    config.braintree_default_merchant_account_id = ENV['BRAINTREE_DEFAULT_MERCHANT_ACCOUNT_ID_DEV']
    
    config.stripe_api_key = ENV['STRIPE_API_KEY']
    config.stripe_public_key = ENV['STRIPE_PUBLIC_KEY']

    # In the development environment your application's code is reloaded on
    # every request. This slows down response time but is perfect for development
    # since you don't have to restart the web server when you make code changes.
    config.cache_classes = false

    # Do not eager load code on boot.
    config.eager_load = false

    # Show full error reports and disable caching.
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    # Don't care if the mailer can't send.
    config.action_mailer.raise_delivery_errors = false

    # Print deprecation notices to the Rails logger.
    config.active_support.deprecation = :log

    # Raise an error on page load if there are pending migrations
    #config.active_record.migration_error = :page_load

    # Debug mode disables concatenation and preprocessing of assets.
    # This option may cause significant delays in view rendering with a large
    # number of complex assets.
    config.assets.debug = true
    
    # show error page set
    config.error_page_ishow=false
end
