class AdminMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "Raisy Admin <support@raisy.entertainment.com>"

  def invite_notification(invite)
      @invite = invite
      mail to: Rails.configuration.admin_email, subject: "New invite: #{@invite.email}"
  end
  
  def registration_codes(order, codes, email)
    @order = order
    @codes = codes
    
    if email != ""
      @order.email = email
    end
    
    mail from: "Raisy <support@raisy.entertainment.com>", to: @order.email, subject: "Your access code for ENTERTAINMENT DIGITAL SAVINGS MEMBERSHIP"
  end
  
  def campaign_summary_closed(campaign)
    @campaign = campaign
    mail from: "Fundraising <fundraising@raisy.entertainment.com>", to: @campaign.organizer.email, subject: "Entertainment Fundraising Result"
  end
  
  def camp_summary_chairperson_weekly(campaign)
    @campaign = campaign
    mail from: "Fundraising <fundraising@raisy.entertainment.com>", to: @campaign.organizer.email, subject: "Entertainment Fundraising Activity"
  end
  
  def camp_summary_seller_weekly(seller)
    @seller = seller
    mail from: "Fundraising <fundraising@raisy.entertainment.com>", to: @seller.user_profile.user.email, subject: "Entertainment Fundraising Activity"
  end
  
  def invite_contacts(from_email, to_email, body, subject)
    @body = body
    
    if from_email == ""
      from_email = "Fundraising <fundraising@raisy.entertainment.com>"
    end
    
    if subject == ""
      subject = "Please support our fundraiser!"
    end
    
    mail from: from_email, to: to_email, subject: subject
  end
end
