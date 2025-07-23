class StudyBadgesController < ApplicationController
  before_action :authenticate_user!

  def index
   # user_study_badgesを先読みしてN+1問題回避
    @study_badges = current_user.study_badges.includes(:user_study_badges)
  end
end
