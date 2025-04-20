class StudyRemindersController < ApplicationController
  # ユーザーが認証されていない場合、アクセスを制限するフィルター
  before_action :authenticate_user!

  # ユーザーの学習リマインダーを一覧表示するアクション
  def index
    # 現在のユーザーに紐づく全ての学習リマインダーを取得
    @study_reminders = current_user.study_reminders

    # カレンダーに表示するイベント情報を整形
    @calendar_events = @study_reminders.map do |reminder|
      {
        title: "学習時間 (#{reminder.start_time.strftime('%H:%M')}〜#{reminder.end_time.strftime('%H:%M')})", # 学習時間のタイトル
        start: reminder.start_time.iso8601,
        end: reminder.end_time.iso8601
      }
    end
  end

  # 新しい学習リマインダーの作成フォームを表示するアクション
  def new
    # 新しい学習リマインダーオブジェクトを作成
    @study_reminder = StudyReminder.new
  end

  # 新しい学習リマインダーをデータベースに保存するアクション
  def create
    # 現在のユーザーに紐づけて、新しい学習リマインダーを作成
    @study_reminder = current_user.study_reminders.new(study_reminder_params)

    # リマインダーが正常に保存された場合
    if @study_reminder.save
      # リマインダーの開始時刻に通知を送信（非同期処理でLineに通知）
      NotifyLineJob.perform_later(@study_reminder.id, :start_time)
      # リマインダーの終了時刻に通知を送信（非同期処理でLineに通知）
      NotifyLineJob.perform_later(@study_reminder.id, :end_time)

      # 学習リマインダー一覧ページにリダイレクト（Turboで遷移させる）
      redirect_to study_reminders_path, status: :see_other
    else
      # リマインダーの保存に失敗した場合、フォームを再表示
      render turbo_stream: turbo_stream.replace(
        "study-reminder-form",  # フォームのIDを指定
        partial: "study_reminders/form",  # 部分テンプレートを指定
        locals: { study_reminder: @study_reminder }  # フォームに使用するリマインダーオブジェクト
      ), status: :unprocessable_entity
    end
  end

  private

  # リクエストから許可されたパラメータを抽出するメソッド
  def study_reminder_params
    params.require(:study_reminder).permit(:start_time, :end_time) # start_time と end_time のみを許可
  end
end
