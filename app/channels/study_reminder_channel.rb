class StudyReminderChannel < ApplicationCable::Channel
  def subscribed
    stream_from "study_reminder_channel_#{current_user.id}"
  end

  def unsubscribed
    # Clean up when the user unsubscribes
  end

  def send_notification(data)
    # 通知メッセージを送信
    StudyReminderChannel.broadcast_to(current_user, message: data["message"])
  end
end
