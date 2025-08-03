class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id]) # ユーザーが見つからなければ例外が発生
    @study_logs = @user.study_logs
  rescue ActiveRecord::RecordNotFound
    redirect_to(root_path, alert: t("users.not_found"))
  end

  def ranking
    @ranking = User.studied_logs_days_ranking
  end

  # 退会理由入力フォームの表示
  def confirm_withdrawal
    # 特に何もしなくてOK（ビューが表示される）
  end

  # 退会理由を保存して退会処理（物理削除）
  def withdraw
    if update_withdrawal_reason
      send_withdrawal_reason_to_google_sheets
      perform_user_withdrawal
    else
      flash.now[:alert] = t("users.withdrawal_reason_invalid")
      render :confirm_withdrawal
    end
  end

  private

  def update_withdrawal_reason
    withdrawal_reason = params.dig(:user, :withdrawal_reason)
    current_user.update(withdrawal_reason: withdrawal_reason)
  end

  def send_withdrawal_reason_to_google_sheets
    GoogleSheetsService.new.append_withdrawal_reason(current_user)
  rescue => e
    Rails.logger.error "Google Sheets 連携エラー: #{e.message}"
    # 失敗しても処理は継続
  end

  def perform_user_withdrawal
    current_user.destroy
    reset_session
    redirect_to root_path, notice: t("users.withdrawal_completed")
  end
end
