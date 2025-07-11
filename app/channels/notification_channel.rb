class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification_channel_#{current_user.id}"
  end

  def unsubscribed
  end

  def send_notification(data)
    NotificationChannel.broadcast_to(current_user, message: data["message"])
  end
end
