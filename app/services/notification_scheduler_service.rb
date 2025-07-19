class NotificationSchedulerService
  def initialize(reminder)
    @reminder = reminder
  end

  def schedule_all
    schedule(:start_time)
    schedule(:end_time)
  end

  private

  def schedule(time_type)
    time = @reminder.send(time_type)
    return unless time&.future?

    ReminderNotificationJob
      .set(wait_until: time)
      .perform_later(@reminder.id, time_type)
  end
end
