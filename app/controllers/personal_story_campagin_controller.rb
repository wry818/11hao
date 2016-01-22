class PersonalStoryCampaginController < ApplicationController
  layout "story_personal"
  def index

  end
  # ajax_supporters
  def supporters

    render partial: "supporters"
  end
end
