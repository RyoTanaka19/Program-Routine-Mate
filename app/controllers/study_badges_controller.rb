class StudyBadgesController < ApplicationController
  before_action :authenticate_user!

  def index
    # 現在ログイン中ユーザーのバッジを取得
    @study_badges = current_user.study_badges
  end
end
