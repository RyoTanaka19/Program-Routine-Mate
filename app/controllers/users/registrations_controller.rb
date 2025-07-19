class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [ :edit, :update ]

  protected

  # サインアップ後のリダイレクト先
  def after_sign_up_path_for(resource)
    study_logs_path
  end

  # ユーザー情報更新時にパスワードなしで更新
  def update_resource(resource, params)
    # パスワードなしでプロフィール更新
    resource.update_without_password(params)
  end

  # 更新後のリダイレクト先
  def after_update_path_for(resource)
    user_path(current_user.id)
  end
end
