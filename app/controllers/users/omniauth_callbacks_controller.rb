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
    basic_action
  end

  private

  # 各SNS（Googleなど）からの認証情報をもとにログイン処理を行う共通メソッド
  def callback_for(provider)
    # SNSから渡されるユーザー情報をもとに、ユーザーを取得または作成します
    @user = User.from_omniauth(request.env["omniauth.auth"])

    # ユーザーをログインさせて、リダイレクトします（Deviseの機能）
    sign_in_and_redirect @user, event: :authentication

    # フラッシュメッセージを表示します（例：「Googleでログインしました」）
    set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
  end

  # SNSログインが失敗した場合の処理（トップページに戻す）
  def failure
    redirect_to root_path
  end

  # LINEなどの柔軟な認証に対応する共通処理
  def basic_action
    # SNSから渡された認証情報を取得
    @omniauth = request.env["omniauth.auth"]

    if @omniauth.present?
      # providerとuidでユーザーを検索。存在しない場合は初期化。
      @profile = User.find_or_initialize_by(provider: @omniauth["provider"], uid: @omniauth["uid"])

      # emailが未設定の場合は、LINEなどでemailが取れないケースを考慮し、ダミーのメールアドレスを設定
      if @profile.email.blank?
        email = @omniauth["info"]["email"] ? @omniauth["info"]["email"] : "#{@omniauth["uid"]}-#{@omniauth["provider"]}@example.com"

        # すでにログイン中のユーザーがいればそれを利用。そうでなければ新規作成。
        @profile = current_user || User.create!(
          provider: @omniauth["provider"],
          uid: @omniauth["uid"],
          email: email,
          name: @omniauth["info"]["name"],
          password: Devise.friendly_token[0, 20] # ランダムなパスワードを生成
        )
      end

      # モデル側で定義されたメソッドで、ユーザー情報を更新
      @profile.set_values(@omniauth)

      # ユーザーをログイン状態にします
      sign_in(:user, @profile)
    end

    # ログイン成功時のフラッシュメッセージを設定
    flash[:notice] = "ログインしました"

    # ログイン後のリダイレクト先（お好きなパスに変更可能）
    redirect_to expendable_items_path
  end
end
