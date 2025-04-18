class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :allow_cors

  def allow_cors
    headers['Access-Control-Allow-Origin'] = "https://program-routine-mate.com"
    headers['Access-Control-Allow-Methods'] = "GET, POST, OPTIONS"
    headers['Access-Control-Allow-Headers'] = "Origin, X-Requested-With, Content-Type, Accept, Authorization"
  end

  protected

  # ログイン後 投稿一覧画面
  def after_sign_in_path_for(study_logs)
    study_logs_path
  end

  # ログアウト後 トップ画面に遷移
  def after_sign_out_path_for(new_user_session)
    root_path
  end

  def configure_permitted_parameters
     devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
     devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :self_introduction, :studying_continuation_systematization, :profile_image, :profile_image_cache ])
  end
end
