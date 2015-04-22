class CollectionsController < ApplicationController

    def index
        @collections = Collection.active
    end

    def show
        @collection = Collection.friendly.find(params[:id])
    end

end
