class PartiesController < ApplicationController

  def index

  end

  def new
   @party=Party.new
  end

  def create

  end
  def edit

  end
  private
  def party_params
    params.require(:parties).permit :name
  end
end
