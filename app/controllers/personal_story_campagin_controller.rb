class PersonalStoryCampaginController < ApplicationController
  layout "story_personal"
  def index

  end

  def index_red_pack

  end
  # ajax_supporters
  def supporters

    render partial: "supporters"
  end
end
