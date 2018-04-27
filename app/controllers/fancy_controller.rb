#encoding: utf-8
class FancyController < ApplicationController

    def index
      @videos = FancylabVideo.order(:id => :desc)
      
      render "index", :layout=>false
    end
    
    def about_us
      render "about_us", :layout=>false
    end
    
    def wei_shop
      # render text: "0" and return
      url = "https://weidian.com/item.html?itemID=2270433038&wfr=c&ifr=itemdetail"

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
end
