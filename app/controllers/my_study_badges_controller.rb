class MyStudyBadgesController < ApplicationController
  before_action :authenticate_user!

  def index
    @badges = current_user.study_badges
  end
end
