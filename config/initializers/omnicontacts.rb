require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
    importer :gmail, 
        Rails.configuration.google_client_id, 
        Rails.configuration.google_client_secret, 
        { :redirect_path => Rails.configuration.google_callback_url }
    
    importer :yahoo, 
        Rails.configuration.yahoo_client_id, 
        Rails.configuration.yahoo_client_secret, 
        { :callback_path => Rails.configuration.yahoo_callback_url }
    
    importer :hotmail, 
        Rails.configuration.mslive_client_id, 
        Rails.configuration.mslive_client_secret, 
        { :redirect_path => Rails.configuration.mslive_callback_url }
    
    importer :facebook, 
      Rails.configuration.facebook_app_id, 
      Rails.configuration.facebook_app_secret, 
      { :redirect_path => Rails.configuration.facebook_callback_url,
        :display => "popup",
        :site => 'https://graph.facebook.com/v2.0',
        :authorize_url => "https://www.facebook.com/v2.0/dialog/oauth"
      }
end