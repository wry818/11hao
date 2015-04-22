class Admin::OrdersController < Admin::ApplicationController
    def index
        @campaign = Campaign.friendly.find(params[:campaign_id])
        @orders = @campaign.orders.completed.order(:id)
    end
end
