# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    callback_for(:google)
  end

  def line
    callback_for(:line)
  end

  def github
    callback_for(:github)
  end

  private

  def callback_for(provider)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.new_record?
      @user.skip_password_validation_on_creation
    end
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
  end
  def failure
    redirect_to root_path
  end
end
