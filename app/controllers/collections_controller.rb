class CollectionsController < ApplicationController

    def index
        @collections = Collection.isnot_destroy.active
    end

    def show
        @collection = Collection.isnot_destroy.friendly.find(params[:id])
    end

end
