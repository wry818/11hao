class Admin::InvitesController < Admin::ApplicationController

    def index
        @invites = Invite.order(:id)
    end

end
