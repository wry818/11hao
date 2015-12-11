class MallController < ApplicationController
  layout "mall"
  
  before_filter :load_campaign, only: [:home]
  before_filter :manage_session_order, only: [:home]
  
  def home
    @products = Product.isnot_destroy.first(6)
  end
  
  private
  
  def load_campaign
    @campaign = Campaign.find_by_id(0)
  end
  
  def manage_session_order
    @order = Order.find_by_id(session[:order_id])
    
    unless @order && @order.campaign_id == @campaign.id && @order.status == 0
      @order = Order.new
    end
  end
end