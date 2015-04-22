class InvitesController < ApplicationController
  
  def contacts_callback
    @contacts = request.env['omnicontacts.contacts']

    # render contacts_callback.html.erb
    render 'contacts_callback', :layout => 'application'
  end
  
end