class UserMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "Raisy <support@raisy.entertainment.com>"

    def payment_confirmation(order, campaign)
        @order = order
        @campaign = campaign
        mail to: @order.email, subject: "Your payment confirmation for #{@campaign.title}"
    end
    
    def consumer_shipment_confirmation(order, campaign)
        @order = order
        @campaign = campaign
        mail to: @order.email, subject: "Your shipment confirmation for #{@campaign.title}"
    end
    
    def chairperson_shipment_confirmation(campaign)
      @campaign = campaign
      mail to: @campaign.organizer.email, subject: "Your shipment confirmation for #{@campaign.title}"
    end
    
    def registration(seller, campaign)
        @seller = seller
        @campaign = campaign
        mail to: @seller.user_profile.user.email, subject: "Welcome to Raisy (Entertainment Fundraising)"
    end
    
    # 13 and under seller, parent is actually creating the account, and we're sending a registration confirmation to the parent
    def parentnotifywith13oldseller(seller, campaign , userprofile)
        @seller = seller
        @campaign = campaign
        @userprofile = userprofile
        mail to: @userprofile.parent_email, subject: "Parent notification from Raisy"
    end
    
    #14-17 year old seller, sending a notification to the parent in addition to the registration confirmation that goes to the seller
    def parentnotifywith14oldseller(seller, campaign , userprofile)
        @seller = seller
        @campaign = campaign
        @userprofile = userprofile
        mail to: @userprofile.parent_email, subject: "Parent notification from Raisy"
    end
    
    def forgotpassword(seller,user)
        @seller = seller
        @user = user
        mail to: @user.email, subject: "Forgot password with Raisy"
    end

end
