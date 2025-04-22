# frozen_string_literal: true

# DeviseのOmniauthCallbacksControllerを継承して、
# SNS認証（GoogleやLINEなど）のコールバックを処理するためのコントローラです。
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Googleアカウントでの認証後に呼び出されるアクション
  def google_oauth2
    # Googleのコールバック処理を共通メソッドに委譲します
    callback_for(:google)
  end

  # LINEでの認証後に呼び出されるアクション
  def line
    # LINE用の柔軟な処理を行う共通メソッドに委譲します
    callback_for(:line)
  end

  def github
    callback_for(:github)
  end

  private

  # 各SNS（Googleなど）からの認証情報をもとにログイン処理を行う共通メソッド
  def callback_for(provider)
    # SNSから渡されるユーザー情報をもとに、ユーザーを取得または作成します
    @user = User.from_omniauth(request.env["omniauth.auth"])

    # もしユーザーが新規作成された場合、password_confirmationのバリデーションをスキップ
    if @user.new_record?
      @user.skip_password_validation_on_creation
    end

    # ユーザーをログインさせて、リダイレクトします（Deviseの機能）
    sign_in_and_redirect @user, event: :authentication

    # フラッシュメッセージを表示します（例：「Googleでログインしました」）
    set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
  end

  # SNSログインが失敗した場合の処理（トップページに戻す）
  def failure
    redirect_to root_path
  end
end
