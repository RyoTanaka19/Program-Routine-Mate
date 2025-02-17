class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protected

  # 新規登録後　投稿一覧画面
  def after_sign_up_path_for(study_logs)
    study_logs_path
  end

  # ログイン後 投稿一覧画面
  def after_sign_in_path_for(study_logs)
    study_logs_path
  end

  # ログアウト後 トップ画面に遷移
  def after_sign_out_path_for(new_user_session)
    root_path
  end

  def configure_permitted_parameters
     # /users/sign_up
     devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :profile_image, :self_introduction ])
  end
end
