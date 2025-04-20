class MyStudyBadgesController < ApplicationController
  # ログインしているユーザーのみがこのコントローラーにアクセスできるようにする
  before_action :authenticate_user!

  # GET /my_study_badges
  # 現在ログインしているユーザーに付与されたバッジの一覧を取得
  def index
    # current_userに関連付けられたstudy_badgesを取得し、ビューで使用できるように@badgesに代入
    @badges = current_user.study_badges
  end
end
