# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150528080304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_settings", force: true do |t|
    t.text     "default_email_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "default_email_message_two"
    t.text     "default_cp_email_message"
    t.text     "default_cp_email_message_two"
  end

  create_table "campaign_bulkshippinginfos", force: true do |t|
    t.integer  "campaign_id"
    t.string   "ship_to_name"
    t.string   "ship_to_attn"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.integer  "state_province_id"
    t.string   "zip_code"
    t.integer  "country_id"
    t.string   "phone_number"
    t.string   "email_address"
    t.datetime "delivery_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_images", force: true do |t|
    t.string   "public_id"
    t.string   "image_id"
    t.boolean  "active",           default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_identifier"
    t.integer  "campaign_id"
    t.boolean  "is_logo"
    t.integer  "image_width"
    t.integer  "image_height"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_width"
    t.integer  "crop_height"
    t.boolean  "is_cropped"
  end

  create_table "campaign_products", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "collection_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_stories", force: true do |t|
    t.text     "story"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_visit_logs", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "seller_id"
    t.string   "remote_ip"
    t.datetime "visited_time"
    t.string   "nickname"
    t.string   "open_id"
  end

  create_table "campaigns", force: true do |t|
    t.integer  "organizer_id"
    t.integer  "collection_id"
    t.integer  "organization_id"
    t.string   "title"
    t.decimal  "goal"
    t.text     "organizer_quote"
    t.text     "description"
    t.text     "delivery_details"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "picture"
    t.integer  "status",                            default: 0,      null: false
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "campaign_type",                     default: 0,      null: false
    t.text     "digital_delivery_instructions"
    t.boolean  "has_pickup",                        default: false,  null: false
    t.text     "pickup_instructions"
    t.boolean  "has_shipping",                      default: false,  null: false
    t.text     "shipping_instructions"
    t.decimal  "shipping_flat_rate"
    t.decimal  "shipping_variable_rate"
    t.string   "logo"
    t.boolean  "charge_processing_to_supporter",    default: false,  null: false
    t.boolean  "charge_processing_to_organization", default: false,  null: false
    t.string   "call_to_action",                    default: "立即购买", null: false
    t.boolean  "tax_deductible_receipt",            default: false,  null: false
    t.boolean  "hide_featured_items",               default: false,  null: false
    t.string   "entertainment_group_id"
    t.boolean  "allow_direct_donation",             default: false
    t.boolean  "is_bulk_submitted",                 default: false
    t.boolean  "is_bulk_ordered",                   default: false
    t.datetime "bulk_submitted_at"
    t.datetime "bulk_ordered_at"
    t.boolean  "is_summary_emailed",                default: false
    t.datetime "summary_emailed_at"
    t.integer  "summary_email_retry_times",         default: 0
    t.text     "email_text"
    t.decimal  "discount"
    t.integer  "purchase_limit"
    t.integer  "discount_counter",                  default: 0
    t.boolean  "active",                            default: true
  end

  add_index "campaigns", ["entertainment_group_id"], name: "index_campaigns_on_entertainment_group_id", unique: true, using: :btree
  add_index "campaigns", ["slug"], name: "index_campaigns_on_slug", unique: true, using: :btree
  add_index "campaigns", ["title"], name: "index_campaigns_on_title", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "picture"
    t.integer  "collection_id"
    t.integer  "parent_category_id"
    t.boolean  "featured",           default: false, null: false
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", unique: true, using: :btree

  create_table "categories_products", id: false, force: true do |t|
    t.integer "category_id", null: false
    t.integer "product_id",  null: false
  end

  add_index "categories_products", ["category_id", "product_id"], name: "index_categories_products_on_category_id_and_product_id", using: :btree
  add_index "categories_products", ["product_id", "category_id"], name: "index_categories_products_on_product_id_and_category_id", using: :btree

  create_table "checkout_option_group_properties", force: true do |t|
    t.integer  "checkout_option_group_id"
    t.string   "value"
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_option_groups", force: true do |t|
    t.integer  "campaign_id"
    t.string   "name"
    t.string   "instructions"
    t.integer  "sort_order"
    t.integer  "buyer_scope",  default: 0,     null: false
    t.boolean  "required",     default: false, null: false
    t.boolean  "deleted",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_options", force: true do |t|
    t.integer  "order_id"
    t.integer  "checkout_option_group_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "picture"
    t.boolean  "active",              default: false, null: false
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "donation_percentage"
    t.text     "landing_page_html"
    t.integer  "sort_order"
  end

  add_index "collections", ["slug"], name: "index_collections_on_slug", unique: true, using: :btree

  create_table "collections_products", id: false, force: true do |t|
    t.integer "collection_id", null: false
    t.integer "product_id",    null: false
  end

  add_index "collections_products", ["collection_id", "product_id"], name: "index_collections_products_on_collection_id_and_product_id", using: :btree
  add_index "collections_products", ["product_id", "collection_id"], name: "index_collections_products_on_product_id_and_collection_id", using: :btree

  create_table "contacts", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email_address"
    t.integer  "user_id"
    t.integer  "media_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "greetings"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbrev"
  end

  create_table "email_share_histories", force: true do |t|
    t.integer  "contact_id"
    t.integer  "seller_id"
    t.datetime "date_sent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ent_orders", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "seller_id"
    t.datetime "order_date"
    t.string   "status"
    t.string   "purchaser_first_name"
    t.string   "purchaser_last_name"
    t.string   "purchaser_email"
    t.decimal  "order_total_amt"
    t.decimal  "unit_price"
    t.integer  "ordered_qty"
    t.string   "entertainment_order_id"
    t.string   "entertainment_group_id"
    t.string   "entertainment_seller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ent_orders", ["entertainment_order_id"], name: "index_ent_orders_on_entertainment_order_id", unique: true, using: :btree

  create_table "inventory_ship_order_files", force: true do |t|
    t.string   "file_source"
    t.string   "file_name"
    t.string   "file_type"
    t.string   "cloud_url"
    t.string   "cloud_public_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "file_status",     default: 0
  end

  create_table "invites", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "organization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "collection_id"
    t.string   "source"
  end

  create_table "items", force: true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "base_amount",            default: 0,     null: false
    t.integer  "donation_amount",        default: 0,     null: false
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delivery_method",        default: 1
    t.integer  "delivery_status",        default: 1
    t.datetime "delivery_updated_at"
    t.string   "rec_id"
    t.boolean  "is_discount",            default: false
    t.integer  "origin_base_amount",     default: 0
    t.integer  "origin_donation_amount", default: 0
    t.string   "tracking_number"
  end

  create_table "option_group_properties", force: true do |t|
    t.integer  "option_group_id"
    t.string   "value"
    t.decimal  "price",                      default: 0.0,   null: false
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "donation_amount",            default: 0.0
    t.string   "sku"
    t.integer  "qty_available",              default: 0
    t.integer  "qty_counter",                default: 0
    t.datetime "inventory_last_update_time"
    t.boolean  "deleted",                    default: false
  end

  create_table "option_groups", force: true do |t|
    t.integer  "product_id"
    t.string   "name"
    t.string   "instructions"
    t.integer  "sort_order"
    t.boolean  "required",     default: false, null: false
    t.boolean  "deleted",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "options", force: true do |t|
    t.integer  "item_id"
    t.integer  "option_group_id"
    t.text     "value"
    t.decimal  "price",                    default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "donation_amount",          default: 0.0
    t.integer  "option_group_property_id"
  end

  create_table "orders", force: true do |t|
    t.integer  "campaign_id"
    t.string   "charge_id"
    t.string   "balanced_hold_uri"
    t.string   "balanced_debit_uri"
    t.string   "balanced_refund_uri"
    t.integer  "status",                      default: 0,     null: false
    t.string   "fullname"
    t.string   "email"
    t.string   "card_type"
    t.string   "card_last_four"
    t.string   "card_expiration_month"
    t.string   "card_expiration_year"
    t.string   "address_line_one"
    t.string   "address_line_two"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_postal_code"
    t.string   "address_country"
    t.string   "billing_zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seller_id"
    t.integer  "delivery_method",             default: 0,     null: false
    t.integer  "shipping_fee",                default: 0,     null: false
    t.integer  "processing_fee_supporter",    default: 0,     null: false
    t.integer  "processing_fee_organization", default: 0,     null: false
    t.string   "address_fullname"
    t.boolean  "make_anonymous",              default: false, null: false
    t.integer  "direct_donation",             default: 0,     null: false
    t.string   "phone_number"
    t.boolean  "is_offline",                  default: false
    t.string   "address_city_area"
    t.string   "out_trade_no"
  end

  create_table "organization_roles", force: true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "access_level",    default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_roles", ["organization_id", "user_id"], name: "index_organization_roles_on_organization_id_and_user_id", using: :btree
  add_index "organization_roles", ["user_id", "organization_id"], name: "index_organization_roles_on_user_id_and_organization_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "picture"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "address_line_one"
    t.string   "address_line_two"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_postal_code"
    t.string   "phone"
    t.string   "email"
    t.string   "website"
    t.string   "legal_name"
    t.string   "legal_tax_id"
    t.string   "legal_address_line_one"
    t.string   "legal_address_line_two"
    t.string   "legal_address_city"
    t.string   "legal_address_state"
    t.string   "legal_address_postal_code"
    t.string   "legal_rep_first_name"
    t.string   "legal_rep_last_name"
    t.string   "legal_rep_dob"
    t.string   "legal_rep_tax_id"
    t.string   "legal_rep_phone"
    t.string   "legal_rep_email"
    t.string   "account_number"
    t.string   "routing_number"
    t.string   "processor_id"
    t.boolean  "use_braintree",             default: false, null: false
    t.string   "entertainment_customer_id"
    t.string   "address_country"
    t.boolean  "deleted",                   default: false
    t.integer  "country_id"
    t.integer  "state_province_id"
  end

  add_index "organizations", ["entertainment_customer_id"], name: "index_organizations_on_entertainment_customer_id", using: :btree
  add_index "organizations", ["name"], name: "index_organizations_on_name", using: :btree
  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "organizations_users", id: false, force: true do |t|
    t.integer "organization_id", null: false
    t.integer "user_id",         null: false
  end

  add_index "organizations_users", ["organization_id", "user_id"], name: "index_organizations_users_on_organization_id_and_user_id", using: :btree
  add_index "organizations_users", ["user_id", "organization_id"], name: "index_organizations_users_on_user_id_and_organization_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "picture"
    t.decimal  "base_price",                 default: 0.0,   null: false
    t.decimal  "default_donation_amount",    default: 0.0,   null: false
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_quantity",              default: true,  null: false
    t.boolean  "needs_shipping",             default: false, null: false
    t.boolean  "is_featured",                default: false, null: false
    t.integer  "fulfillment_method"
    t.string   "sku"
    t.integer  "qty_available",              default: 0
    t.integer  "qty_counter",                default: 0
    t.datetime "inventory_last_update_time"
    t.string   "vendor"
    t.decimal  "original_price",             default: 0.0,   null: false
    t.integer  "vendor_id"
  end

  add_index "products", ["slug"], name: "index_products_on_slug", unique: true, using: :btree

  create_table "pv_transmission_calendars", force: true do |t|
    t.string   "calendar_name"
    t.string   "product_group"
    t.string   "external_id"
    t.datetime "delivery_date"
    t.datetime "submission_date"
  end

  create_table "registration_codes", force: true do |t|
    t.string   "reg_code"
    t.integer  "product_id"
    t.integer  "is_used",    default: 0
    t.integer  "order_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sellers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "referral_code"
    t.integer  "campaign_id"
    t.integer  "user_profile_id"
    t.string   "grade"
    t.string   "homeroom"
    t.text     "email_text"
  end

  add_index "sellers", ["campaign_id", "user_profile_id"], name: "index_sellers_on_campaign_id_and_user_profile_id", using: :btree
  add_index "sellers", ["referral_code"], name: "index_sellers_on_referral_code", unique: true, using: :btree
  add_index "sellers", ["user_profile_id", "campaign_id"], name: "index_sellers_on_user_profile_id_and_campaign_id", using: :btree

  create_table "social_share_histories", force: true do |t|
    t.integer  "seller_id"
    t.integer  "media_id"
    t.string   "post_id"
    t.datetime "date_shared"
  end

  create_table "state_provinces", force: true do |t|
    t.integer  "country_id"
    t.string   "abbrev"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_profiles", force: true do |t|
    t.integer  "user_id",                           null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "picture"
    t.string   "display_name"
    t.string   "title"
    t.string   "parent_email"
    t.string   "parent_first_name"
    t.string   "parent_last_name"
    t.boolean  "child_profile",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_number"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "remember_token"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin_flag",             default: false, null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "account_type"
    t.boolean  "is_fake",                default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

  create_table "vendors", force: true do |t|
    t.string  "name"
    t.string  "email"
    t.boolean "active",  default: true
    t.boolean "deleted", default: false
  end

end
