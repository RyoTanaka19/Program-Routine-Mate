class UsersController < ApplicationController
  # Deviseでユーザーがログインしている場合、current_user でアクセスできます
  # ここで before_action を使用して、全てのアクションでユーザーがログインしているかを確認します。
  # もしログインしていない場合は、ログインページにリダイレクトされます。
  before_action :authenticate_user!  # ユーザーがログインしていることを確認

  # ユーザーのプロフィールページを表示するアクション
  def show
    # current_user を使って、現在ログインしているユーザーを取得します。
    # @user にその情報を格納し、ビューで使用できるようにします。
    @user = User.find(params[:id])

    # ユーザーが行った学習ログを @study_logs に格納してビューで表示できるようにします。
    # current_user.study_logs で、現在のユーザーに関連付けられた学習ログを取得します。
    @study_logs = @user.study_logs
  end

  # ユーザーが獲得したバッジを表示するアクション
  def badges
    # current_user で現在ログインしているユーザーを取得し、そのユーザーが獲得したバッジを取得します。
    # @study_badges にその情報を格納してビューで表示します。
    @study_badges = current_user.study_badges
  end
end
