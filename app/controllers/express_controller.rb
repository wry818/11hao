class ExpressController < ApplicationController
  include ExpressHelper
  def order_express
    # session[:openid] = "oaR9aswmRKvGhMdb6kJCgIFKBpeg1"
    # return @order= Order.find_by_id(params[:order_id])
    # return @order = Order.find_by_id(params[:order_id])
    if session[:openid]
      @item = Item.find(params[:item_id])
      @courier_number=params[:courier_number]
      if @courier_number==nil
        @courier_number=@item.courier_number
      end
    else
      redirect_to root_path and return
    end
  end
  def order_express_ajax

    # session[:openid] = "oaR9aswmRKvGhMdb6kJCgIFKBpeg1"
    # return @order= Order.find_by_id(params[:order_id])
    # return @order = Order.find_by_id(params[:order_id])
    # if session[:openid]
      @item = Item.find(params[:item_id])
      @courier_number=params[:courier_number]
      if @courier_number==nil
        @courier_number=@item.courier_number
      end
      # @docresult = Nokogiri::XML(open('http://www.kuaidiapi.cn/rest/?uid=53100&key=2c40a2e81f354f02b052e3ba58de615c&order=710093138324&id=yuantong&show=xml&ord=desc'))
      # @docresult.encoding = "utf-8"
      begin
        @docresult=get_doc(@item.express, @courier_number)
      rescue
        logger.error "物流信息API调用发生错误！"
        render :text => "error" and return
      end

      errcode=@docresult.xpath('//xmlns:errcode').text
      if errcode!="0000"
        render :text => "0000" and return
      end

      # logger.debug @docresult.xpath('//xmlns:status').text
      # logger.debug get_status_text(@docresult.xpath('//xmlns:status').text)
      @exprss_status=get_status_text(@docresult.xpath('//xmlns:status').text)
      # logger.debug @exprss_status

      @times= @docresult.xpath('//xmlns:data//xmlns:data//xmlns:time')
      @display=@docresult.xpath('//xmlns:data//xmlns:data//xmlns:content')
      # docresult.xpath('//xmlns:data//xmlns:data//xmlns:time').each do |temp|
      #  logger.debug @times[0]
      # end
      render :partial => "express"
    # else
    #   redirect_to root_path and return
    # end
  end
end
