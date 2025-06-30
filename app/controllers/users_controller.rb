class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @study_logs = @user.study_logs
  end

  def badges
    @study_badges = current_user.study_badges
  end
end
