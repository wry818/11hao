#encoding: utf-8
class FancyController < ActionController::Base

    def index
      @videos = FancylabVideo.order(:id => :desc)
      
      render "index", :layout=>false
    end
    
    def lottery
      render "lottery", :layout=>false
    end
    
    def about_us
      render "about_us", :layout=>false
    end
    
    def wei_shop
      @shop_url = ShopUrl.first
      url = @shop_url.url

      redirect_to url and return
    end
    
    def video_like
      video = FancylabVideo.find_by_id(params[:id])
      
      if video
        video.video_likes += 1
        video.save
        
        render text: video.video_likes.to_s and return
      end
      
      render text: "0" and return
    end
    
    def vop
    
      require 'net/http'
    
      begin
    
        upload = params[:data]
        Rails.logger.info upload.original_filename
    
        origin_path = Rails.root.join('public', 'uploads', upload.original_filename)
        puts origin_path
        File.open(origin_path, 'wb') do |file|
            file.write(upload.read)
        end
        Rails.logger.info "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        converted_path = Rails.root.join('public', 'uploads', upload.original_filename.first(upload.original_filename.length - 4) + ".pcm")
        Rails.logger.info converted_path
        system "ffmpeg -y  -i '" + origin_path.to_s + "'  -acodec pcm_s16le -f s16le -ac 1 -ar 16000 '" + converted_path.to_s + "'"
      
        base64String = Base64.strict_encode64(File.open(converted_path).read)
        size = File.size(converted_path)

        uri = URI('https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=fX326ZiM4MonMnLVaoorw5WI&client_secret=bwkC8OCc1E0c8rttc3XCyTVWglm4d1vu')

        Net::HTTP.start(uri.host, uri.port,
          :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Get.new uri

          response = http.request(request)

          @json = JSON.parse(response.body)
          access_token = @json["access_token"]


          url = URI('http://vop.baidu.com/server_api')
          request = Net::HTTP::Post.new(url.to_s)

          request.add_field('Content-Type', 'application/json')
          request.body = {
                    # dev_pid: 1537,
                    format: "pcm",
                    rate: 16000,
                    channel: 1,
                    token: access_token,
                    cuid: "1234567JAVA",
                    len: size,
                    speech: base64String
                }.to_json

          response = Net::HTTP.start(url.host, url.port) {|http|
            http.request(request)
          }

          @json = JSON.parse(response.body)
          result = @json["result"]
          
          puts response.body
          render json: {code: 200, result: result}.to_json
        
        end
    
      rescue => exception
      
        render json: {code: 500, result: exception.message}.to_json
    
      end
    
    end
    
end
