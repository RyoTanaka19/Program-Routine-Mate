# frozen_string_literal: true

# パスワード再設定に関するコントローラー（Deviseを継承）
class Users::PasswordsController < Devise::PasswordsController
  # パスワード再設定メールの送信処理
  def create
    # 入力されたメールアドレスにリセット手順を送信
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      # 送信成功時、リダイレクト
      redirect_to after_sending_reset_password_instructions_path_for(resource_name)
    else
      # 入力エラーに応じてフラッシュメッセージを設定
      if resource.email.blank?
        flash[:alert] = "メールアドレスを入力してください"
      elsif !resource.persisted?
        flash[:alert] = "そのメールアドレスは登録されていません"
      else
        flash[:alert] = "エラーが発生しました。もう一度お試しください。"
      end
      respond_with resource
    end
  end

  # パスワード再設定処理
  def update
    # トークンによりパスワードをリセット
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      # 成功時、ログインさせてリダイレクト
      flash[:notice] = "パスワードが変更されました" if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      # バリデーションエラーをログ出力 & 表示
      Rails.logger.debug("Validation Errors: #{resource.errors.full_messages}")
      flash[:alert] = resource.errors.full_messages.join("、") if is_navigational_format?
      respond_with resource
    end
  end

  protected

  # パスワード再設定後の遷移先
  def after_resetting_password_path_for(resource)
    study_logs_path
  end
end
