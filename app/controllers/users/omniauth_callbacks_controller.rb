# frozen_string_literal: true

# DeviseのOmniauthCallbacksControllerを継承して、
# GoogleやLINE、GitHubなどのSNS認証のコールバックを処理するコントローラ。
# SNSでのログインが完了した後、このコントローラが呼び出されます。
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Googleアカウントでの認証後に呼び出されるアクション
  def google_oauth2
    # Google用のコールバック処理を共通メソッドに渡して実行
    callback_for(:google)
  end

  # LINEアカウントでの認証後に呼び出されるアクション
  def line
    # LINE用のコールバック処理を共通メソッドに渡して実行
    callback_for(:line)
  end

  private

  # 各SNS（Google, LINE, GitHubなど）から返ってきた認証情報を使って
  # ユーザーのログイン処理を共通で行うメソッド
  def callback_for(provider)
    # SNSから渡されたユーザー情報をもとに、既存のユーザーを探すか新規作成します。
    # 情報はrequest.env["omniauth.auth"]に格納されています。
    @user = User.from_omniauth(request.env["omniauth.auth"])

    # ユーザーが新規作成された場合は、パスワード確認（confirmation）の
    # バリデーションをスキップする処理を呼び出します。
    # SNSログインではパスワードを使わないため。
    if @user.new_record?
      @user.skip_password_validation_on_creation
    end

    # ログイン処理を行い、ユーザーをサインイン状態にします。
    # Deviseのヘルパーメソッドで、同時にリダイレクトも実行されます。
    sign_in_and_redirect @user, event: :authentication

    # フラッシュメッセージ（成功通知）を表示します。
    # 例：「Googleでログインしました」
    set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
  end

  # SNSログインに失敗した場合の処理
  # ルートパス（トップページ）にリダイレクトします。
  def failure
    redirect_to root_path
  end
end
