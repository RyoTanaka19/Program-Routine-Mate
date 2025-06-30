class StudyReminderChannel < ApplicationCable::Channel
  def subscribed
    stream_from "study_reminder_channel_#{current_user.id}"
  end

  def unsubscribed
  end

  def send_notification(data)
    StudyReminderChannel.broadcast_to(current_user, message: data["message"])
  end
end
