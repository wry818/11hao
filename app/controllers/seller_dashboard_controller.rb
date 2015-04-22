class SellerDashboardController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  
    before_filter :authenticate_user!

    def index

        if current_user.account_type == 3  #parent accounts

            @child_profiles = current_user.child_profiles

            if params[:seller_referral_code]
                @seller = Seller.where(referral_code: params[:seller_referral_code]).first
                redirect_to(seller_dashboard_path, flash: { warning: "Sorry, we couldn't find the seller" }) and return unless @seller && @seller.user_profile.user == current_user

                @sellers = @seller.user_profile.sellers
            else
                @sellers = @child_profiles.first.sellers
                @seller = @sellers.first
            end

        else
            if params[:seller_referral_code]
                @seller = Seller.where(referral_code: params[:seller_referral_code]).first
                redirect_to(seller_dashboard_path, flash: { warning: "Sorry, we couldn't find the seller" }) and return unless @seller && @seller.user_profile.user == current_user
            else
                @seller = current_user.profile.sellers.first
            end
            
            @sellers = current_user.profile.sellers
        end
        
        @contacts = @seller.user_profile.user.contacts
        @campaign = @seller.campaign
        @email_msg = @seller.email_text || ""
    
        if @email_msg != ""
            # {{fundraiser.title}} - Title of fundraiser
            # {{fundraiser.tagline}} - Tagline of fundraiser
            # {{fundraiser.goal}} - Goal of fundraiser
            # {{fundraiser.url}} - Url of fundraiser
            # {{fundraiser.chairperson}} - Title of fundraiser
            # {{fundraiser.signup.url}} - Url of seller signup
            # {{organization.name}} - Organization name
            # {{collection.name}} - Collection name
            # {{seller.fullname}} - Seller's fullname
            # {{seller.url}} - Url of seller's fundraiser page

            @email_msg = @email_msg.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
            @email_msg = @email_msg.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
            @email_msg = @email_msg.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
            @email_msg = @email_msg.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
            @email_msg = @email_msg.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
            @email_msg = @email_msg.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
            @email_msg = @email_msg.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
            @email_msg = @email_msg.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
            @email_msg = @email_msg.gsub(/\{\{seller\.fullname\}\}/, @seller.user_profile.fullname)
            @email_msg = @email_msg.gsub(/\{\{seller\.url\}\}/, short_campaign_url(@campaign, seller: @seller.referral_code))
        end
        
        @admin_setting = AdminSetting.first
        @default_email_msg = ""
        @default_email_msg_two = ""
        
        if @admin_setting
            @default_email_msg = @admin_setting.default_email_message || ""
            
            if @default_email_msg != ""
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
                @default_email_msg = @default_email_msg.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{seller\.fullname\}\}/, @seller.user_profile.fullname)
                @default_email_msg = @default_email_msg.gsub(/\{\{seller\.url\}\}/, short_campaign_url(@campaign, seller: @seller.referral_code))
                @default_email_msg = @default_email_msg.gsub(/\{\{contact\.greeting\}\}/, "")
            end
            
            @default_email_msg_two = @admin_setting.default_email_message_two || ""
            
            if @default_email_msg != ""
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{seller\.fullname\}\}/, @seller.user_profile.fullname)
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{seller\.url\}\}/, short_campaign_url(@campaign, seller: @seller.referral_code))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{contact\.greeting\}\}/, "")
            end
        end
    end
    
    def seller_orders_download
      # see views/seller_dashboard/seller_orders_download.xlsx.axlsx
      @seller = Seller.where(referral_code: params[:seller_referral_code]).first
      
      render xlsx: "seller_orders_download", filename: "my_orders.xlsx"
    end
end
