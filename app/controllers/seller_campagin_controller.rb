class SellerCampaginController < ApplicationController

  layout "seller"

  def index

    @campaigns=Campaign.where(:fundraising_event_id=>1)
    ids=""

    @campaigns.each do |i|
      ids+=i.id.to_s+","
    end

    @current_rank = 0
    ids=ids.chop
    logger.debug ids


    # ladder today
    query = QueryHelper.get_ladder_campaign(ids,"")
    @seller_ladder_result = ActiveRecord::Base.connection.execute(query)

    if @seller_ladder_result&&@seller_ladder_result.count>0
      @seller_today_first=@seller_ladder_result[0]
      @campaign_first=Campaign.find(@seller_today_first["id"])
    end

    query = QueryHelper.get_ladder_campaign(ids,DateTime.now.to_date.to_s)
    @seller_ladder_today_result = ActiveRecord::Base.connection.execute(query)

    if @seller_ladder_today_result&&@seller_ladder_today_result.count>0
      @seller_today_top=@seller_ladder_today_result[0]
      @campaign_top=Campaign.find(@seller_today_top["id"])
    end

    # if !@campaign_top
    #   if @seller_ladder_result&&@seller_ladder_result.count>0
    #     @seller_today_top=@seller_ladder_result[0]
    #     @campaign_top=Campaign.find(@seller_today_top["id"])
    #   end
    # end

  end
end
