class StudyRemindersController < ApplicationController
  before_action :authenticate_user!

  def index
    @study_reminders = current_user.study_reminders
    @calendar_events = @study_reminders.map do |reminder|
      {
        title: "学習セッション",
        start: reminder.start_time.strftime("%Y-%m-%dT%H:%M:%S"),
        end: reminder.end_time.strftime("%Y-%m-%dT%H:%M:%S"),
        description: "学習時間"
      }
    end
  end

  def events
    @study_reminders = current_user.study_reminders
    @calendar_events = @study_reminders.map do |reminder|
      {
        title: "学習セッション",
        start: reminder.start_time.strftime("%Y-%m-%dT%H:%M:%S"),
        end: reminder.end_time.strftime("%Y-%m-%dT%H:%M:%S"),
        description: "学習時間"
      }
    end
    render json: @calendar_events
  end


  def new
    @study_reminder = StudyReminder.new
  end

  def create
    @study_reminder = current_user.study_reminders.new(study_reminder_params)

    if @study_reminder.save
      NotifyLineJob.perform_later(@study_reminder.id, :start_time)
      NotifyLineJob.perform_later(@study_reminder.id, :end_time)

      # Turboにリダイレクトさせる方法
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
    params.require(:study_reminder).permit(:start_time, :end_time)
  end
end
