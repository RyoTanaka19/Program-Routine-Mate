# frozen_string_literal: true

# SNS認証後のコールバック処理を行うコントローラー
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Googleログイン時の処理
  def google_oauth2
    callback_for(:google)
  end

  # LINEログイン時の処理
  def line
    callback_for(:line)
  end

  # GitHubログイン時の処理
  def github
    callback_for(:github)
  end

  private

  def callback_for(provider)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.new_record?
      @user.skip_password_validation = true
      unless @user.save
        redirect_to root_path, alert: "認証に失敗しました。" and return
      end
    end

    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
  end

  # 認証失敗時の処理（トップページへ）
  def failure
    redirect_to root_path
  end
end
