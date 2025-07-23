class StudyBadgesController < ApplicationController
  before_action :authenticate_user!

  def index
    @study_badges = current_user.study_badges.includes(:user_study_badges)
  end
end
