class UsersController < ApplicationController
  # Deviseでユーザーがログインしている場合、current_user でアクセスできます
  before_action :authenticate_user!  # ユーザーがログインしていることを確認

  def badges
    # current_user で現在ログインしているユーザーを取得
    @study_badges = current_user.study_badges
  end
end
