# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      redirect_to after_sending_reset_password_instructions_path_for(resource_name)
    else
      # メールアドレスが未入力の場合や他のエラーがある場合にエラーメッセージをflashに追加
      if resource.errors[:email].any?
        flash[:alert] = "メールアドレスを入力してください"
      else
        flash[:alert] = "エラーが発生しました。もう一度お試しください。"
      end
      respond_with resource
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      flash[:notice] = "パスワードが変更されました" if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      # エラーメッセージがない場合のデバッグ
      Rails.logger.debug("Validation Errors: #{resource.errors.full_messages}")
      flash[:alert] = resource.errors.full_messages.join("、") if is_navigational_format?
      respond_with resource
    end
  end

  protected

  # パスワードリセット後のリダイレクト先を設定
  def after_resetting_password_path_for(resource)
    study_logs_path
  end
end
