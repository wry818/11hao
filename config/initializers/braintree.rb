# if Rails.env.production?
#     Braintree::Configuration.environment = :production
#     Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID_PROD']
#     Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY_PROD']
#     Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY_PROD']
# else
#     Braintree::Configuration.environment = :sandbox
#     Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID_DEV']
#     Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY_DEV']
#     Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY_DEV']
# end

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID_DEV']
Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY_DEV']
Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY_DEV']