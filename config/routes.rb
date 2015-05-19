Raisy::Application.routes.draw do
  
  mount WeixinRailsMiddleware::Engine, at: "/"
    root 'pages#index'

    devise_for :users,:controllers => {:registrations => "registrations"}
    
    devise_scope :user do 
      get 'signup_social_user', to: 'registrations#signup_social_user'
    end
    
    get "/auth/failure", to: "users#omniauth_failure"
    get "/auth/twitter/callback", to: "users#omniauth_callback"
    get "/auth/facebook/callback", to: "users#omniauth_callback"
    
    match "/user/verify" => "users#verify_user", via: [:get, :post]
    match "/user/lookup" => "users#lookup_user", via: [:get, :post]

    namespace :admin do
        root 'dashboard#index'
        
        resources :collections do
            resources :categories
        end
        
        resources :products do
          get '/option_group/edit', to: 'products#edit_option_group', as: :edit_option_group
          match '/option_group/save' => 'products#save_option_group', via: [:post, :patch], as: :save_option_group
          delete '/option_group/delete', to: 'products#delete_option_group', as: :delete_option_group
          post '/option_group_property/:id/save', to: 'products#save_option_group_property', as: :save_option_group_property
          delete '/option_group_property/:id/delete', to: 'products#delete_option_group_property', as: :delete_option_group_property
        end
        
        resources :invites
        resources :organizations
        resources :users
        
        resources :campaigns do
            resources :orders
        end
        
        resources :settings
        resources :vendors
        
        get 'campaign_stories', to: 'campaigns#stories'
        get 'campaign_story/:id', to: 'campaigns#story'
        post 'campaign_save_story', to: 'campaigns#save_story'
        
        get 'campaign_images', to: 'campaigns#images'
        get 'campaign_image', to: 'campaigns#image'
        get 'campaign_delete_image', to: 'campaigns#delete_image'
        post 'campaign_save_image', to: 'campaigns#save_image'
        
        get 'default_email_message', to: 'settings#default_email_message'
        post 'save_default_email_message', to: 'settings#save_default_email_message'
        get 'default_chairperson_email_message', to: 'settings#default_chairperson_email_message'
        post 'save_default_chairperson_email_message', to: 'settings#save_default_chairperson_email_message'
        
        get 'campaign_bulkshippinginfo/:id', to: 'campaigns#bulkshippinginfo', as: :campaign_bulkshippinginfo
        post 'campaign_bulkshippinginfo/:id/create', to: 'campaigns#create_bulkshippinginfo', as: :campaign_bulkshippinginfos
        patch 'campaign_bulkshippinginfo/:id', to: 'campaigns#update_bulkshippinginfo'
        
        get 'product_collections/:id', to: 'products#prod_collections', as: :product_collections
        
    end

    resources :collections
    resources :organizations
    resources :campaigns, except: [:show]
    
    # CAMPAIGNS
    get "ajax/campsteppopup", to: "campaigns#ajax_camp_step_popup", as: :ajax_camp_step_popup
    
    scope 'campaigns' do
      get ':id/preview', to: 'campaigns#campaign_preview', as: :campaign_preview
      get ':id/contacts', to: 'campaigns#campaign_contacts', as: :campaign_contacts
      get ':id/sendmails', to: 'campaigns#campaign_sendmails', as: :campaign_sendmails
      get ':id/share', to: 'campaigns#campaign_share', as: :campaign_share
      get 'account', to: 'campaigns#campaign_account', as: :campaign_account
      post 'create_account', to: 'campaigns#campaign_create_account', as: :campaign_create_account
      post 'ajax_create', to: 'campaigns#ajax_create', as: :campaign_ajax_create
    end

    get 'search', to: 'pages#search', as: :search
    get 'ajax/searchcamppopup', to: 'pages#ajax_search_camp_popup', as: :ajax_search_camp_popup

    # STATIC PAGES
    get 'privacy', to: 'pages#privacy'
    get 'tou', to: 'pages#tou'
    get 'copyright', to: 'pages#copyright'

    post 'ajax/invite', to: 'pages#ajax_invite', as: :ajax_invite
    
    #USERS
    get 'signup', to: 'users#new', as: :signup
    post 'signup', to: 'users#create', as: :signup_create
    get 'profile/:id', to: 'users#show', as: :user

    #SETTINGS
    scope 'settings' do
        get 'profile', to: 'users#settings_profile', as: :settings_profile
        match 'profile', via: [:put, :patch], to: 'users#update_profile', as: :update_profile
        get 'account', to: 'users#settings_account', as: :settings_account
        match 'account', via: [:put, :patch], to: 'users#update_account', as: :update_account
    end

    #SELLER SIGN UP
    get 'seller/signup/:campaign_id', to: 'users#signup_seller', as: :signup_seller
    get 'seller/photo/:seller_id', to: 'users#seller_photo', as: :seller_photo
    get 'seller/share/:seller_id', to: 'users#signup_seller_share', as: :signup_seller_share
    post 'seller/finish/:seller_id', to: 'users#signup_seller_finish', as: :signup_seller_finish
    post 'seller/photo/:seller_id', to: 'users#update_seller_photo', as: :update_seller_photo
    post 'seller/signup/:campaign_id', to: 'users#signup_seller_create', as: :signup_seller_create
    post 'seller/add/:campaign_id', to: 'users#signup_seller_add', as: :signup_seller_add
    get 'seller/contacts/:id', to: 'users#seller_contacts', as: :seller_get_contacts
    get 'seller/mycontacts/:id', to: 'users#seller_my_contacts', as: :seller_my_contacts
    get 'seller/emailcontacts/:id', to: 'users#seller_email_contacts', as: :seller_email_contacts
    get 'seller/sendemails/:id', to: 'users#seller_sendemails', as: :seller_sendemails
    post 'ajax/previewcontactemail', to: 'users#ajax_preview_contact_email', as: :ajax_preview_contact_email
    post 'ajax/invitecontacts', to: 'users#ajax_invite_contacts', as: :ajax_seller_invite_contacts
    post 'ajax/importcontacts', to: 'users#ajax_import_contacts', as: :ajax_seller_import_contacts
    post 'ajax/updatecontact', to: 'users#ajax_update_contact', as: :ajax_seller_update_contact
    post 'ajax/emailcontacts', to: 'users#ajax_email_contacts', as: :ajax_seller_email_contacts
    post 'ajax/socialshare', to: 'users#ajax_social_share', as: :ajax_seller_social_share
    get "/invites/:provider/contact_callback" => "invites#contacts_callback"
  	get "/contacts/failure" => "invites#failure"
    delete "seller/contacts/:id", to: 'users#seller_delete_contacts', as: :seller_delete_contacts
    post "ajax/deletecontact", to: 'users#ajax_delete_contact', as: :ajax_seller_delete_contact
    get "ajax/sellersteppopup", to: "users#ajax_seller_step_popup", as: :ajax_seller_step_popup
    
    #SELLER DASHBOARD
    scope 'seller' do
        root 'seller_dashboard#index', as: :seller_dashboard
        get ':seller_referral_code', to: 'seller_dashboard#index', as: :seller_dashboard_referral_code
        get ':seller_referral_code/orders/download', to: 'seller_dashboard#seller_orders_download', as: :seller_orders_download
    end

    #CHAIRPERSON DASHBOARD
    scope 'chairperson' do
      get 'sales_report', to: 'chairperson_dashboard#sales_report', as: :sales_report
      get 'sales_report_content', to: 'chairperson_dashboard#sales_report_content', as: :sales_report_content
      get 'sales_report_download', to: 'chairperson_dashboard#sales_report_download', as: :sales_report_download
      
      scope 'storefronts' do
        root 'chairperson_dashboard#storefronts', as: :dashboard_storefronts
      end
      
      scope 'campaigns' do
          root 'chairperson_dashboard#campaigns', as: :dashboard_campaigns
          get ':id', to: 'chairperson_dashboard#campaign', as: :dashboard_campaign
          get ':id/details', to: 'chairperson_dashboard#campaign_details', as: :dashboard_campaign_details
          get ':id/sellers', to: 'chairperson_dashboard#campaign_sellers', as: :dashboard_campaign_sellers
          get ':id/order/:order_id', to: 'chairperson_dashboard#campaign_order', as: :dashboard_campaign_order
          get ':id/orders', to: 'chairperson_dashboard#campaign_orders', as: :dashboard_campaign_orders
          get ':id/orders/download', to: 'chairperson_dashboard#campaign_orders_download', as: :dashboard_campaign_orders_download
          get ':id/delivery', to: 'chairperson_dashboard#campaign_delivery', as: :dashboard_campaign_delivery
          patch ':id/delivery', to: 'campaigns#update_delivery', as: :campaign_update_delivery
          get ':id/bulkshippinginfo', to: 'chairperson_dashboard#campaign_bulkshippinginfo', as: :dashboard_campaign_bulkshippinginfo
          get ':id/contacts', to: 'chairperson_dashboard#campaign_contacts', as: :dashboard_campaign_contacts
          get ':id/sendmails', to: 'chairperson_dashboard#campaign_sendmails', as: :dashboard_campaign_sendmails
      end
      scope 'organizations' do
          root 'chairperson_dashboard#organizations', as: :dashboard_organizations
          get ':id', to: 'chairperson_dashboard#organization', as: :dashboard_organization
          get ':id/details', to: 'chairperson_dashboard#organization_details', as: :dashboard_organization_details
          patch ':id/details', to: 'organizations#update_details', as: :organization_update_details
          get ':id/deposit', to: 'chairperson_dashboard#organization_deposit', as: :dashboard_organization_deposit
          patch ':id/deposit', to: 'organizations#update_deposit', as: :organization_update_deposit
      end
    end

    # SHOPPING
    post 'ajax/update-cart', to: 'shop#ajax_update_cart', as: :ajax_update_cart
    post 'ajax/update-delivery', to: 'shop#ajax_update_delivery', as: :ajax_update_delivery
    post 'ajax/order-summary', to: 'shop#ajax_order_summary', as: :ajax_order_summary
    post 'ajax/addofflineorder', to: 'shop#ajax_add_offline_order', as: :ajax_add_offline_order
    post "ajax/resendaccesscode", to: 'shop#ajax_resend_access_code', as: :ajax_resend_access_code
    get 'checkout/:id', to: 'shop#checkout', as: :checkout
    get ':id/shop', to: 'shop#shop', as: :shop
    get ':id/shop/category/:category_id', to: 'shop#category', as: :shop_category
    get ':id/shop/category/:category_id/product/:product_id', to: 'shop#product', as: :shop_category_product
    get ':id/shop/product/:product_id', to: 'shop#product', as: :shop_product
    
    get ':id/confirmation', to: 'shop#show_confirmation', as: :show_confirmation
    post ':id/confirmation', to: 'shop#checkout_confirmation', as: :checkout_confirmation

    get ':id/supporters', to: 'shop#supporters', as: :supporters
    get ':id', to: 'shop#show', as: :short_campaign
    
    get 'campaigns/organizations.json', to: 'campaigns#get_organizations'
    get 'campaigns/organization.json/:id', to: 'campaigns#get_organization'
    get 'campaigns/collections.json', to: 'campaigns#get_collections'
    
    post ':id/bulkshippinginfo/create', to: 'campaigns#create_bulkshippinginfo', as: :campaign_bulkshippinginfos
    patch ':id/bulkshippinginfo/edit', to: 'campaigns#update_bulkshippinginfo', as: :campaign_bulkshippinginfo
    
    match 'upload/campaign_photo' => 'upload#campaign_photo', via: [:post, :patch]
    
    # WEIXIN
    scope 'weixin_custom' do
        get 'menu' => 'weixin#menu'
        get 'menulist' => 'weixin#menulist'
        get 'authorize' => 'weixin#authorize'
        get 'test' => 'weixin#test'
        post 'notify' => 'weixin#notify'
        get 'address' => 'weixin#address'
    end
    
end
