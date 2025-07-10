class StudyRemindersController < ApplicationController
  before_action :authenticate_user!

  def index
    @study_reminders = current_user.study_reminders
    @study_logs = current_user.study_logs.where.not(date: nil)
  end

  def new
    @study_reminder = StudyReminder.new

if params[:date]
  date = Date.parse(params[:date])
  @study_reminder.start_time = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
  @study_reminder.end_time = @study_reminder.start_time
end
  end

  def create
    @study_reminder = current_user.study_reminders.new(study_reminder_params)
    if @study_reminder.save
      NotifyUserJob.perform_later(@study_reminder.id, :start_time)
      NotifyUserJob.perform_later(@study_reminder.id, :end_time)
      flash[:notice] = "学習開始時間と学習終了時間が設定されました"
      redirect_to study_reminders_path, status: :see_other
    else
      render turbo_stream: turbo_stream.replace(
        "study-reminder-form",
        partial: "study_reminders/form",
        locals: { study_reminder: @study_reminder }
      ), status: :unprocessable_entity
    end
  end

  private

  def study_reminder_params
    params.require(:study_reminder).permit(:start_time, :end_time, :title)
  end
end
