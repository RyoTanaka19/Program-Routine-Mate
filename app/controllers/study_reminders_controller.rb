class StudyRemindersController < ApplicationController
  before_action :authenticate_user!

  def index
    @study_reminders = current_user.study_reminders.order(start_time: :asc)
    @study_logs = current_user.study_logs.where.not(date: nil)
  end

  def new
    @study_reminder = StudyReminder.new
    set_start_and_end_time_from_date_param if params[:date].present?
  end

 def create
  @study_reminder = current_user.study_reminders.new(study_reminder_params)

  if @study_reminder.save
    begin
      NotificationSchedulerService.new(@study_reminder).schedule_all
    rescue StandardError => e
      Rails.logger.error("[NotificationSchedulerService] Failed to schedule notifications: #{e.message}")
      flash[:alert] = "学習リマインダーは保存されましたが、通知の設定に失敗しました。管理者にお問い合わせください。"
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "学習開始時間と学習終了時間が設定されました"
        render :create
      end
      format.html do
        flash[:notice] ||= "学習開始時間と学習終了時間が設定されました"
        redirect_to study_reminders_path, status: :see_other
      end
    end
  else
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "study-reminder-form",
          partial: "study_reminders/form",
          locals: { study_reminder: @study_reminder }
        ), status: :unprocessable_entity
      end
      format.html do
        render :new, status: :unprocessable_entity
      end
    end
  end
end


  private

  def set_start_and_end_time_from_date_param
    begin
      date = Date.parse(params[:date])
      @study_reminder.start_time = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
      @study_reminder.end_time = @study_reminder.start_time
    rescue ArgumentError
      # 不正な日付だった場合はnilに設定しておく（必要に応じてログ記録やユーザー通知も検討）
      @study_reminder.start_time = nil
      @study_reminder.end_time = nil
    end
  end

  def study_reminder_params
    params.require(:study_reminder).permit(:start_time, :end_time, :title)
  end
end
