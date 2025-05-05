class StudyRemindersController < ApplicationController
  # ユーザーが認証されていない場合、アクセスを制限するフィルター
  before_action :authenticate_user!

  # ユーザーの学習リマインダーを一覧表示するアクション
  def index
    @study_reminders = current_user.study_reminders
  end

  # 新しい学習リマインダーの作成フォームを表示するアクション
  def new
    # 新しい学習リマインダーオブジェクトを作成
    @study_reminder = StudyReminder.new

    # 日付がURLパラメータで渡されていれば、その日付をstart_timeにセット
    if params[:date]
      @study_reminder.start_time = Date.parse(params[:date]).to_time
      @study_reminder.end_time = @study_reminder.start_time
    end
  end

  # 新しい学習リマインダーをデータベースに保存するアクション
  def create
    # 現在のユーザーに紐づけて、新しい学習リマインダーを作成
    @study_reminder = current_user.study_reminders.new(study_reminder_params)
  
    if @study_reminder.save
      # 通知ジョブを非同期で実行
      NotifyLineJob.perform_later(@study_reminder.id, :start_time)
      NotifyLineJob.perform_later(@study_reminder.id, :end_time)
  
      # ✅ フラッシュメッセージを設定
      flash[:notice] = "学習開始時間と学習終了時間が設定されました"
  
      # 一覧ページへリダイレクト（Turbo対応）
      redirect_to study_reminders_path, status: :see_other
    else
      # 保存に失敗した場合、フォームをTurbo Streamsで再描画
      render turbo_stream: turbo_stream.replace(
        "study-reminder-form",
        partial: "study_reminders/form",
        locals: { study_reminder: @study_reminder }
      ), status: :unprocessable_entity
    end
  end
  

  private

  # リクエストから許可されたパラメータを抽出するメソッド
  def study_reminder_params
    params.require(:study_reminder).permit(:start_time, :end_time) # start_time と end_time のみを許可
  end
end
