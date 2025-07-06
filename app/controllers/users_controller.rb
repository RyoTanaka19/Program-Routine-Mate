class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @study_logs = @user.study_logs
  end

  def badges
    @study_badges = current_user.study_badges
  end

  # 退会理由入力フォームの表示
  def confirm_withdrawal
    # 特に何もしなくてOK（ビューが表示される）
  end

  # 退会理由を保存して退会処理（物理削除）
  def withdraw
    withdrawal_reason = params.dig(:user, :withdrawal_reason)  # 安全に取得
    current_user.assign_attributes(withdrawal_reason: withdrawal_reason)

    if current_user.save
      begin
        # Google Sheetsに送信（連携サービスがあればここで呼ぶ）
        GoogleSheetsService.new.append_withdrawal_reason(current_user)
      rescue => e
        Rails.logger.error "Google Sheets 連携エラー: #{e.message}"
        # 失敗しても退会処理は続行
      end

      # 退会（物理削除）
      current_user.destroy
      reset_session
      redirect_to root_path, notice: '退会が完了しました。ご利用ありがとうございました。'
    else
      flash.now[:alert] = '退会理由の入力に問題があります'
      render :confirm_withdrawal
    end
  end
end
