Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Rails.configuration.twitter_app_id, Rails.configuration.twitter_app_secret
  provider :facebook, Rails.configuration.facebook_app_id, Rails.configuration.facebook_app_secret, :display=>"popup", :client_options => {
      :site => 'https://graph.facebook.com/v2.0',
      :authorize_url => "https://www.facebook.com/v2.0/dialog/oauth"
    }
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}