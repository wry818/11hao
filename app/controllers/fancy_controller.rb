#encoding: utf-8
class FancyController < ApplicationController

    def index
      render "index", :layout=>false
    end
    def about_us
      render "about_us", :layout=>false
    end
end
