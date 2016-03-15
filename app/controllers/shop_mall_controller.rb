class ShopMallController < ApplicationController
  layout "shop_weixin"

  def pay

  end

  def product
    @product = Product.friendly.find(params[:product_id])

    # redirect_to(short_campaign_url(@campaign), flash: { warning: "抱歉，我们没有找到这个商品" }) and return unless @product && (@product.collections.include?(@campaign.collection) || @campaign.used_as_default?)

    @category = params[:category_id] ? Category.friendly.find(params[:category_id]) : false
    @qty_avail = @product.need_check_inventory ? @product.qty_available-@product.qty_counter : 99999

    @option_group = @product.option_groups.active.first
    @option_group_properties = []
    @option_group_is_dropdown = false
    @discount = 1
    @min_price = (@discount * @product.total_price * 100).ceil/100.0
    @max_price = (@discount * @product.total_price * 100).ceil/100.0
    @min_origin_price = (@product.original_price * 100).ceil/100.0
    @max_origin_price = (@product.original_price * 100).ceil/100.0

    # if @campaign.is_discount?
    #     @discount = (100 - @campaign.discount)/100.0
    # end

    if @option_group
      @min_price = 99999
      @max_price = 0
      @min_origin_price = 99999
      @max_origin_price = 0

      has_properties = false

      @option_group.option_group_properties.active.each do |property|
        @option_group_is_dropdown = true

        if property.can_be_ordered?(1)
          has_properties = true

          prop_price = (property.total_price * @discount * 100).ceil/100.0
          prop_origin_price = (@product.original_price * 100).ceil/100.0

          @option_group_properties << property

          if prop_price<=@min_price
            @min_price=prop_price
          end

          if prop_price>=@max_price
            @max_price=prop_price
          end

          if prop_origin_price<=@min_origin_price
            @min_origin_price=prop_origin_price
          end

          if prop_origin_price>=@max_origin_price
            @max_origin_price=prop_origin_price
          end
        end
      end

      if !has_properties
        @min_price = (@discount * @product.total_price * 100).ceil/100.0
        @max_price = (@discount * @product.total_price * 100).ceil/100.0
        @min_origin_price = (@product.original_price * 100).ceil/100.0
        @max_origin_price = (@product.original_price * 100).ceil/100.0
      end
    else
      @min_price = (@discount * @product.total_price * 100).ceil/100.0
      @max_price = (@discount * @product.total_price * 100).ceil/100.0
      @min_origin_price = (@product.original_price * 100).ceil/100.0
      @max_origin_price = (@product.original_price * 100).ceil/100.0
    end
  end
end
