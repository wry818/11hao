# encoding: utf-8
# 1, @weixin_message: 获取微信所有参数.
# 2, @weixin_public_account: 如果配置了public_account_class选项,则会返回当前实例,否则返回nil.
# 3, @keyword: 目前微信只有这三种情况存在关键字: 文本消息, 事件推送, 接收语音识别结果
WeixinRailsMiddleware::WeixinController.class_eval do

  def reply
    # logger.info "aaaaaaaaaaaaaaaaaaa"
    render xml: send("response_#{@weixin_message.MsgType}_message", {})
  end

  private

    def response_text_message(options={})
      
      # reply_text_message("aaaaaa")

      open_id = @weixin_message.FromUserName
      content = "#{@keyword}"

      logger.info "#{@keyword}"

      if content.include? "#筹款"

        # logger.info "aaaaaaaaaaaaaaa"

        slug = content.split(' ')

        if slug.length > 1

          campaign_slug = slug[1]

          # logger.info "bbbbbbbbbbbbbbb"
#           logger.info campaign_slug

          begin

            campaign = Campaign.friendly.find(campaign_slug)

            if campaign && campaign.active?

              $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
              articles = [
                {
                  title: "感谢您的支持!",
                  description: "现在只需点击创建您的个人筹款页面。",
                  url: request.protocol + request.host + "/seller/signup_weixin/" + campaign_slug
                }
              ]

              $wechat_client.send_news_custom(open_id, articles)

            else

              reply_text_message('抱歉，未找到相应活动，请以"#筹款 代码"的格式重新输入筹款活动代号。')

            end

          rescue

            reply_text_message('抱歉，未找到相应活动，请以"#筹款 代码"的格式重新输入筹款活动代号。')

          end
            
        else

          reply_text_message('请以"#筹款 代码"的格式输入筹款活动代号')

        end
        
      elsif content == "11"
        
        $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
        articles = [
          {
            title: "11号公益圈粉丝专享福利",
            url: "http://evt.dianping.com/event/mmbonus/new/newlanding.html?source=gongyi",
            picurl: request.protocol + request.host + "/images/hongbao.jpg"
          }
        ]

        $wechat_client.send_news_custom(open_id, articles)
          
      else
        
        reply_transfer_customer_service_message()

      end

    end

    # <Location_X>23.134521</Location_X>
    # <Location_Y>113.358803</Location_Y>
    # <Scale>20</Scale>
    # <Label><![CDATA[位置信息]]></Label>
    def response_location_message(options={})
      @lx    = @weixin_message.Location_X
      @ly    = @weixin_message.Location_Y
      @scale = @weixin_message.Scale
      @label = @weixin_message.Label
      reply_text_message("您的当前位置: #{@lx}, #{@ly}, #{@scale}, #{@label}")
    end

    # <PicUrl><![CDATA[this is a url]]></PicUrl>
    # <MediaId><![CDATA[media_id]]></MediaId>
    def response_image_message(options={})
      @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      @pic_url  = @weixin_message.PicUrl  # 也可以直接通过此链接下载图片, 建议使用carrierwave.
      # reply_image_message(generate_image(@media_id))
      reply_transfer_customer_service_message()
    end

    # <Title><![CDATA[公众平台官网链接]]></Title>
    # <Description><![CDATA[公众平台官网链接]]></Description>
    # <Url><![CDATA[url]]></Url>
    def response_link_message(options={})
      @title = @weixin_message.Title
      @desc  = @weixin_message.Description
      @url   = @weixin_message.Url
      # reply_text_message("回复链接信息")
      reply_transfer_customer_service_message()
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <Format><![CDATA[Format]]></Format>
    def response_voice_message(options={})
      @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      @format   = @weixin_message.Format
      # 如果开启了语音翻译功能，@keyword则为翻译的结果
      # reply_text_message("回复语音信息: #{@keyword}")
      # reply_voice_message(generate_voice(@media_id))
      reply_transfer_customer_service_message()
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    def response_video_message(options={})
      
      open_id = @weixin_message.FromUserName
      
      logger.info "response_video_message" + open_id
      
      weixin_user_info = UserWeixinCache.get(open_id)

      if weixin_user_info && weixin_user_info.campaign_slug
        
        campaign = Campaign.friendly.find(weixin_user_info.campaign_slug)
    
        if campaign && campaign.active?
          
          @media_id = @weixin_message.MediaId
          $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
          uri = $wechat_client.download_media_url(@media_id)

          file_name = "video_" + DateTime.now.strftime("%Y%m%d%H%M%S") + SecureRandom.hex(2)

          require 'open-uri'
          open('./public/videos/' + file_name + ".mp4", 'wb') do |file|

            file << open(uri).read

            weixin_user_info.video_url = file_name
            UserWeixinCache.set(open_id, weixin_user_info)
    
            articles = [
              {
                title: "太棒了！您的募捐视频上传成功！",
                description: "现在只需点击创建您的个人筹款页面。",
                url: request.protocol + request.host + "/seller/signup_weixin/" + weixin_user_info.campaign_slug + "/" + weixin_user_info.video_url
              }
            ]
    
            $wechat_client.send_news_custom(open_id, articles)

          end
        
        else
          
          reply_text_message('抱歉，未找到相应活动，请以"#筹款 代码"的格式重新输入筹款活动代号。')
        
        end
         
      else
        
         reply_text_message('您尚未输入筹款活动代码，请以"#筹款 代码"的格式输入筹款活动代码')
         
      end
      
    end

    def response_event_message(options={})
      event_type = @weixin_message.Event
      send("handle_#{event_type.downcase}_event")
    end

    # 关注公众账号
    def handle_subscribe_event
      if @keyword.present?
        # 扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送
        # return reply_text_message("扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送, keyword: #{@keyword}")
        return reply_text_message("感谢您关注11号公益圈！")
      end
      return reply_text_message("感谢您关注11号公益圈！")
    end

    # 取消关注
    def handle_unsubscribe_event
      Rails.logger.info("取消关注")
    end

    # 扫描带参数二维码事件: 2. 用户已关注时的事件推送
    def handle_scan_event
      reply_text_message("扫描带参数二维码事件: 2. 用户已关注时的事件推送, keyword: #{@keyword}")
    end

    def handle_location_event # 上报地理位置事件
      @lat = @weixin_message.Latitude
      @lgt = @weixin_message.Longitude
      @precision = @weixin_message.Precision
      reply_text_message("您的当前地理位置: #{@lat}, #{@lgt}, #{@precision}")
    end

    # 点击菜单拉取消息时的事件推送
    def handle_click_event
      reply_text_message("你点击了: #{@keyword}")
    end

    # 点击菜单跳转链接时的事件推送
    def handle_view_event
      Rails.logger.info("你点击了: #{@keyword}")
    end

    # 帮助文档: https://github.com/lanrion/weixin_authorize/issues/22

    # 由于群发任务提交后，群发任务可能在一定时间后才完成，因此，群发接口调用时，仅会给出群发任务是否提交成功的提示，若群发任务提交成功，则在群发任务结束时，会向开发者在公众平台填写的开发者URL（callback URL）推送事件。

    # 推送的XML结构如下（发送成功时）：

    # <xml>
    # <ToUserName><![CDATA[gh_3e8adccde292]]></ToUserName>
    # <FromUserName><![CDATA[oR5Gjjl_eiZoUpGozMo7dbBJ362A]]></FromUserName>
    # <CreateTime>1394524295</CreateTime>
    # <MsgType><![CDATA[event]]></MsgType>
    # <Event><![CDATA[MASSSENDJOBFINISH]]></Event>
    # <MsgID>1988</MsgID>
    # <Status><![CDATA[sendsuccess]]></Status>
    # <TotalCount>100</TotalCount>
    # <FilterCount>80</FilterCount>
    # <SentCount>75</SentCount>
    # <ErrorCount>5</ErrorCount>
    # </xml>
    def handle_masssendjobfinish_event
      Rails.logger.info("回调事件处理")
    end

end
