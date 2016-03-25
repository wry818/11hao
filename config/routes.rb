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

        resources :product_categories do
          match 'product_categories/new', to: 'product_categories#subclassnew',via:[:get], as: :new_product_category_subclass
          post 'product_categories', to: 'product_categories#subclasscreate', as: :create_product_category_subclass
          get 'product_categories', to: 'product_categories#subclassindex', as: :index_product_category_subclass
          delete 'product_categories/:id', to: 'product_categories#subclassdestroy', as: :delete_product_category_subclass
          get  'product_categories/:id/edit', to: 'product_categories#subclassedit', as: :edit_product_category_subclass
          get  'product_categories/:id', to: 'product_categories#subclassshow', as: :show_product_category_subclass
          match  'product_categories/:id', to: 'product_categories#subclassupdate',via: [:patch,:put], as: :update_product_category_subclass

          get  'product_categories/ajax/select', to: 'product_categories#sublass_ajax_select', as: :show_product_category_subclass_ajax_select
          resources :product_categories
        end

        get 'products/ajax',to: 'products#show_pager_data', as: :load_products_show_pager_data
        post 'products/ajax',to: 'products#show_pager_data', as: :products_show_pager_data
        resources :products do
          get '/option_group/edit', to: 'products#edit_option_group', as: :edit_option_group
          match '/option_group/save' => 'products#save_option_group', via: [:post, :patch], as: :save_option_group
          delete '/option_group/delete', to: 'products#delete_option_group', as: :delete_option_group
          post '/option_group_property/:id/save', to: 'products#save_option_group_property', as: :save_option_group_property
          delete '/option_group_property/:id/delete', to: 'products#delete_option_group_property', as: :delete_option_group_property
        end
        
        resources :invites
        resources :organizations
        post 'organizations/ajax',to: 'organizations#ajax_pager_data', as: :organizations_page_ajax
        resources :users
        
        resources :campaigns do
            resources :orders
        end
        post 'campaigns/ajax',to: 'campaigns#ajax_pager_data', as: :campaigns_page_ajax
        
        resources :settings
        resources :vendors

        resources :tags
        post 'tags/ajax',to: 'tags#ajax_pager_data', as: :tags_page_ajax
        post  'tags/search_ajax',to:"tags#search_ajax", as: :tags_search_ajax
        post  'tags/ajax_delete',to: 'tags#ajax_delete', as: :tags_ajax_delete
        
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
        
        namespace :reports do
          root 'reportsboard#index'
          get 'campvisit_log/report',to: 'campaign_visit_log#reportindex', as: :campvisit_log_report
          post 'campvisit_log/report',to: 'campaign_visit_log#reportsearch', as: :campvisit_log_report_search
        end
        
        resources :questionnaires
      
        get 'mall_settings', to: 'mall#settings', as: :mall_settings
        post 'save_mall_settings', to: 'mall#save_settings', as: :save_mall_settings

        resources :express_upload
        get 'express/load_excle',to: 'express_upload#load_excle',as: :express_load_excle_ajax
        get 'express/validate',to: 'express_upload#validate_check',as: :express_validate_ajax
        get 'express/update',to: 'express_upload#update_data',as: :express_update_ajax
        get 'express/donload',to: 'express_upload#donload',as: :express_donload
    end

  #Express
  get 'order_express/:item_id/:courier_number', to: 'express#order_express', as: :order_express
  get 'order_express_ajax/:item_id/:courier_number', to: 'express#order_express_ajax', as: :order_express_ajax
  get 'order_express_ajax', to: 'express#order_express_ajax', as: :order_express_ajax_get


    # Mall
    scope 'mall' do
      root 'mall#home', as: :mall_home
      match 'search' => 'mall#search', via: [:get, :post], as: :mall_search
      match 'search_page' => 'mall#search_page', via: [:get, :post], as: :mall_search_page
      get 'orders', to: 'mall#orders', as: :mall_orders
      get 'orders_page', to: 'mall#orders_page', as: :mall_orders_page
      get 'order_detail/:id', to: 'mall#order_detail', as: :mall_order_detail
    end

    resources :collections
    resources :organizations
    resources :campaigns, except: [:show]

  get 'shopmall/product/:product_id', to: 'shop_mall#product', as: :shop_mall_product
  get 'shopmall/pay', to: 'shop_mall#pay', as: :shop_mall_product_pay
  # get 'shopmall/product_id', to: 'shop_mall#product', as: :shop_mall_product_view
    #personal_story
  get 'checkout/lzds', to: 'campaign_ngo#lzds', as: :campagin_ngo_lzds
  get 'campaginngo/lzds_supporters', to: 'campaign_ngo#lzds_supporters', as: :campagin_ngo_lzds_supporters

  get 'checkout/lovehb', to: 'campaign_ngo#lovehb', as: :campagin_ngo_lovehb
  get 'campaginngo/lovehb_supporters', to: 'campaign_ngo#lovehb_supporters', as: :campagin_ngo_lovehb_supporters

  get 'checkout/xgst', to: 'campaign_ngo#xgst', as: :campagin_ngo_xgst
  get 'campaginngo/xgst_supporters', to: 'campaign_ngo#xgst_supporters', as: :campagin_ngo_xgst_supporters

  get 'checkout/:id', to: 'campaign_ngo#campaignview',constraints: { id: /campaign_[0-9]*/ }, as: :campagin_ngo_campaignview
  get 'campaginngo/campaignview_supporters', to: 'campaign_ngo#campaignview_supporters', as: :campagin_ngo_campaignview_supporters

  get 'checkout/shgs', to: 'campaign_ngo#shgs', as: :campagin_ngo_shgs
  get 'campaginngo/shgs_supporters', to: 'campaign_ngo#shgs_supporters', as: :campagin_ngo_shgs_supporters

  get 'checkout/xyetjk', to: 'campaign_ngo#xyetjk', as: :campagin_ngo_xyetjk
  get 'campaginngo/xyetjk_supporters', to: 'campaign_ngo#xyetjk_supporters', as: :campagin_ngo_xyetjk_supporters

  get 'checkout/lbxgy', to: 'campaign_ngo#lbxgy', as: :campagin_ngo_lbxgy
  get 'campaginngo/lbxgy_supporters', to: 'campaign_ngo#lbxgy_supporters', as: :campagin_ngo_lbxgy_supporters

  get 'checkout/lbflower', to: 'campaign_ngo#lbflower', as: :campagin_ngo_lbflower
  get 'campaginngo/lbflower_supporters', to: 'campaign_ngo#lbflower_supporters', as: :campagin_ngo_lbflower_supporters

  post 'campaginngo/confirmation', to: 'campaign_ngo#confirmation', as: :campaign_ngo_checkout_confirmation
  post 'campaginngo/confirmation_weixin', to: 'campaign_ngo#confirmation_weixin', as: :campaign_ngo_confirmation_weixin

    get 'personal_story_campagin/my_influence', to: 'personal_story_campagin#my_influence', as: :personal_story_campagin_my_influence
    get 'personal_story_campagin/get_red_pack', to: 'personal_story_campagin#get_red_pack', as: :personal_story_campagin_get_red_pack
    get 'checkout/supportcampagin', to: 'personal_story_campagin#index', as: :personal_story_campagin_index
    get 'checkout/supportcampagin_old', to: 'personal_story_campagin#index_old', as: :personal_story_campagin_index_old
    get 'checkout/supportcampagin/:id', to: 'personal_story_campagin#index', as: :personal_story_campagin_share_index
    get 'checkout/sunflower', to: 'personal_story_campagin#sunflower', as: :personal_story_campagin_sunflower
    get 'personal_story_campagin/sunflower_supporters', to: 'personal_story_campagin#sunflower_supporters', as: :personal_story_campagin_sunflower_supporters
  get 'checkout/pulushi', to: 'personal_story_campagin#pulushi', as: :personal_story_campagin_pulushi
  get 'personal_story_campagin/pulushi_supporters', to: 'personal_story_campagin#pulushi_supporters', as: :personal_story_campagin_pulushi_supporters
  get 'checkout/mtyg', to: 'personal_story_campagin#mtyg', as: :personal_story_campagin_mtyg
  get 'personal_story_campagin/mtyg_supporters', to: 'personal_story_campagin#mtyg_supporters', as: :personal_story_campagin_mtyg_supporters
  get 'checkout/handonhand', to: 'personal_story_campagin#handonhand', as: :personal_story_campagin_handonhand
  get 'personal_story_campagin/handonhand_supporters', to: 'personal_story_campagin#handonhand_supporters', as: :personal_story_campagin_handonhand_supporters
  get 'checkout/qnpjs', to: 'personal_story_campagin#qnpjs', as: :personal_story_campagin_qnpjs
  get 'personal_story_campagin/qnpjs_supporters', to: 'personal_story_campagin#qnpjs_supporters', as: :personal_story_campagin_qnpjs_supporters
  get 'checkout/xgy', to: 'personal_story_campagin#xgy', as: :personal_story_campagin_xgy
  get 'personal_story_campagin/xgy_supporters', to: 'personal_story_campagin#xgy_supporters', as: :personal_story_campagin_xgy_supporters
  get 'checkout/lzgy', to: 'personal_story_campagin#lzgy', as: :personal_story_campagin_lzgy
  get 'personal_story_campagin/lzgy_supporters', to: 'personal_story_campagin#lzgy_supporters', as: :personal_story_campagin_lzgy_supporters
  get 'checkout/bjlyr', to: 'personal_story_campagin#bjlyr', as: :personal_story_campagin_bjlyr
  get 'personal_story_campagin/bjlyr_supporters', to: 'personal_story_campagin#bjlyr_supporters', as: :personal_story_campagin_bjlyr_supporters
  get 'checkout/xlzh', to: 'personal_story_campagin#xlzh', as: :personal_story_campagin_xlzh
  get 'personal_story_campagin/xlzh_supporters', to: 'personal_story_campagin#xlzh_supporters', as: :personal_story_campagin_xlzh_supporters
  get 'checkout/ydw', to: 'personal_story_campagin#ydw', as: :personal_story_campagin_ydw
  get 'personal_story_campagin/ydw_supporters', to: 'personal_story_campagin#ydw_supporters', as: :personal_story_campagin_ydw_supporters
  get 'checkout/chq', to: 'personal_story_campagin#chq', as: :personal_story_campagin_chq
  get 'personal_story_campagin/chq_supporters', to: 'personal_story_campagin#chq_supporters', as: :personal_story_campagin_chq_supporters


    post 'personal_story_campagin/confirmation', to: 'personal_story_campagin#confirmation', as: :personal_story_campagin_checkout_confirmation
    post 'personal_story_campagin/confirmation_weixin', to: 'personal_story_campagin#confirmation_weixin', as: :personal_story_campagin_checkout_confirmation_weixin
    get ':id/confirmation_personal_campagin', to: 'personal_story_campagin#confirmation_personal_campagin', as: :show_confirmation_personal_campagin
    post 'ajax/supportcampagin/supporters', to: 'personal_story_campagin#supporters', as: :ajax_personal_story_campagin_supporters
    get 'checkout/supportcampagin_red', to: 'personal_story_campagin#index_red_pack', as: :personal_story_campagin_index_red_pack
    post 'ajax/checkout/supportcampagin/share', to: 'personal_story_campagin#share', as: :personal_story_campagin_share
    post 'ajax/checkout/supportcampagin/share_success', to: 'personal_story_campagin#share_result', as: :personal_story_campagin_share_result
    get '1rmb/ranking', to: 'seller_campagin#index', as: :personal_story_seller_ladder

    get 'checkout/supportlanlan', to: 'personal_story#index', as: :personal_story_index
    get 'personal_story/supporters', to: 'personal_story#supporters', as: :personal_story_supporters
    get 'personal_story/refresh', to: 'personal_story#refresh', as: :personal_story_refresh


    resources :personal_story
    post 'personal_story/confirmation', to: 'personal_story#checkout_confirmation', as: :personal_story_checkout_confirmation
    post 'personal_story/confirmation_weixin', to: 'personal_story#checkout_confirmation_weixin', as: :personal_story_checkout_confirmation__weixin
    get ':id/confirmation_personal', to: 'personal_story#show_confirmation', as: :show_confirmation_personal

    get 'checkout/supportjujube', to: 'personal_story_jujube#index', as: :personal_story_jujube_index

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
    get 'tos', to: 'pages#tos'
    get 'reg_tos', to: 'pages#reg_tos'

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
    get 'seller/signup_weixin/:campaign_id', to: 'users#signup_seller_weixin', as: :signup_seller_weixin
    get 'seller/signup_weixin_video/:seller_referral_code', to: 'users#signup_seller_weixin_video', as: :signup_seller_weixin_video
    post 'seller/signup_weixin_create', to: 'users#signup_seller_weixin_create', as: :signup_seller_weixin_create
    patch 'seller/signup_weixin_update', to: 'users#signup_seller_weixin_update', as: :signup_seller_weixin_update
    get 'user/order_list', to: 'users#order_list', as: :user_order_list
    get 'user/order_detail/:order_id', to: 'users#order_detail', as: :user_order_detail
    get 'seller/campaign_list', to: 'users#campaign_list', as: :seller_campaign_list
    
    #SELLER DASHBOARD
    scope 'seller' do
        root 'seller_dashboard#index', as: :seller_dashboard
        get ':seller_referral_code', to: 'seller_dashboard#index', as: :seller_dashboard_referral_code
        get ':seller_referral_code/orders/download', to: 'seller_dashboard#seller_orders_download', as: :seller_orders_download
        get ':seller_referral_code/seller_ladder', to: 'seller_dashboard#seller_ladder', as: :seller_ladder
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
    post 'ajax/update-order', to: 'shop#ajax_update_order', as: :ajax_update_order
    post 'ajax/query-weixin-order', to: 'shop#ajax_query_weixin_order', as: :ajax_query_weixin_order
    post 'ajax/update-order-address', to: 'shop#ajax_update_order_address', as: :ajax_update_order_address
    
    # match "checkout/weixin_notify" => "shop#weixin_notify", via: [:get, :post]
    # post 'checkout/weixin_notify', to: 'shop#weixin_notify', as: :checkout_weixin_notify
    get 'weixin_payment_get_req/:id', to: 'shop#weixin_payment_get_req', as: :weixin_payment_get_req
  get 'checkout/checkout_weixin', to: 'shop#checkout_weixin', as: :checkout_weixin
    get 'checkout/:id', to: 'shop#checkout', as: :checkout

    get 'checkout/:id/weixin_native_pay', to: 'shop#weixin_native_pay', as: :checkout_weixin_native_pay
    post 'checkout/weixin_notify', to: 'shop#weixin_notify', as: :checkout_weixin_notify
    get ':id/shop', to: 'shop#shop', as: :shop
    get ':id/shop/category/:category_id', to: 'shop#category', as: :shop_category
    get ':id/shop/category/:category_id/product/:product_id', to: 'shop#product', as: :shop_category_product
    get ':id/shop/product_weixin/:product_id', to: 'shop#product_weixin', as: :shop_product_weixin
  get ':id/shop/product/:product_id', to: 'shop#product', as: :shop_product
    get ':id/confirmation', to: 'shop#show_confirmation', as: :show_confirmation
   get ':id/confirmation_weixin', to: 'shop#show_confirmation_weixin', as: :show_confirmation_weixin
    post ':id/confirmation', to: 'shop#checkout_confirmation', as: :checkout_confirmation
    get ':id/checkout_support', to: 'shop#checkout_support', as: :checkout_support
    get ':id/checkout_support_page', to: 'shop#checkout_support_page', as: :checkout_support_page

    get ':id/supporters', to: 'shop#supporters', as: :supporters
    get ':id', to: 'shop#show', as: :short_campaign
    
    get 'campaigns/organizations.json', to: 'campaigns#get_organizations'
    get 'campaigns/organization.json/:id', to: 'campaigns#get_organization'
    get 'campaigns/collections.json', to: 'campaigns#get_collections'
    
    post ':id/bulkshippinginfo/create', to: 'campaigns#create_bulkshippinginfo', as: :campaign_bulkshippinginfos
    patch ':id/bulkshippinginfo/edit', to: 'campaigns#update_bulkshippinginfo', as: :campaign_bulkshippinginfo
    
    match 'upload/campaign_photo' => 'upload#campaign_photo', via: [:post, :patch]
    match 'upload/product_photo' => 'upload#product_photo', via: [:post, :patch]
    match 'upload/photo' => 'upload#photo', via: [:post, :patch]

    post 'upload/photo_croper' => 'upload#photo_croper'
    # WEIXIN
    scope 'weixin_custom' do
        get 'menu' => 'weixin#menu'
        get 'menulist' => 'weixin#menulist'
        get 'test' => 'weixin#test'
        get 'video' => 'weixin#video'
        post 'video' => 'weixin#video_post', as: :video_post
        get 'native' => 'weixin#native_mode2'
        get 'query_order/:id' => 'weixin#query_order'
        # match "native_callback" => "weixin#native_callback", via: [:get, :post]
        # post 'native_callback' => 'weixin#native_callback'
        match "notify" => "weixin#notify", via: [:get, :post]
        # post 'notify' => 'weixin#notify'
        # post 'notify_alert' => 'weixin#notify_alert'
        get 'send_template' => 'weixin#send_template'
        get 'send_message' => 'weixin#send_message'
        post 'ajax/query-weixin-order', to: 'weixin#ajax_query_weixin_order'
        
        get 'download' => 'weixin#download_file'
        
    end

    # if !Rails.env.production?
    # get '404', :to => 'application#page_not_found'
    # get '500', :to => 'application#page_not_found'
    # end
    # make sure this rule is the last one
    #  get '*path' => proc { |env| Rails.env.development? ? (raise ActionController::RoutingError, %{No route matches "#{env["PATH_INFO"]}"}) : ApplicationController.action(:render_not_found).call(env) }
    # get '*unmatched_route', :to => 'application#raise_not_found!'

    match '*path' => proc { |env| ApplicationController.action(:page_not_found).call(env) },via: [:get]
end
