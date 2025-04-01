# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  # callback for google
  def google_oauth2
    callback_for(:google)
  end

  def callback_for(provider)
    # 先ほどuser.rbで記述したメソッド(from_omniauth)をここで使っています
    # 'request.env["omniauth.auth"]'この中にgoogoleアカウントから取得したメールアドレスや、名前と言ったデータが含まれています
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
  end

  def failure
    redirect_to root_path
  end

  def line
    basic_action
  end

  private

  def basic_action
    @omniauth = request.env["omniauth.auth"]
    if @omniauth.present?
      @profile = User.find_or_initialize_by(provider: @omniauth["provider"], uid: @omniauth["uid"])
      
      # emailが空の場合、OmniAuthの情報からemailを設定
      if @profile.email.blank?
        email = @omniauth["info"]["email"] ? @omniauth["info"]["email"] : "#{@omniauth["uid"]}-#{@omniauth["provider"]}@example.com"
        
        # パスワード生成
        password = Devise.friendly_token[0, 20]
        
        # current_userがいない場合は新しいユーザーを作成（passwordとpassword_confirmationを一致させる）
        @profile = current_user || User.create!(provider: @omniauth["provider"], uid: @omniauth["uid"], email: email, name: @omniauth["info"]["name"], password: password, password_confirmation: password)
      end
      
      # OmniAuth情報をセット
      @profile.set_values(@omniauth)
      
      # ログイン
      sign_in(:user, @profile)
      
      # ログイン後のflash messageとリダイレクト先を設定
      flash[:notice] = "ログインしました"
      
      # リダイレクト先を設定
      redirect_to study_logs_path
    else
      flash[:alert] = "認証情報が取得できませんでした"
      redirect_to root_path # 取得できなかった場合にリダイレクト
    end
  end
end
