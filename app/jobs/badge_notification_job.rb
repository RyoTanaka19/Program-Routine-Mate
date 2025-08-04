class BadgeNotificationJob < ApplicationJob
  queue_as :default

  def perform(badge_id, user_id)
    badge = StudyBadge.find_by(id: badge_id)
    user  = User.find_by(id: user_id)

    unless badge && user
      Rails.logger.warn("バッジまたはユーザーが見つかりません: badge_id=#{badge_id}, user_id=#{user_id}")
      return
    end

    message = "🎉 #{user.name}さんが「#{badge.name}」バッジを獲得しました！"

    begin
      send_line_notification(message, user)
    rescue => e
      Rails.logger.error("LINE通知送信エラー: #{e.class} - #{e.message}")
    end

    begin
      broadcast_notification(user.id, message)
    rescue => e
      Rails.logger.error("ブラウザ通知送信エラー: #{e.class} - #{e.message}")
    end
  end

  private

  def send_line_notification(message, user)
    return if user.uid.blank?

    client = LINE_BOT_API
    client.push_message(user.uid, { type: "text", text: message })
  end

  def broadcast_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", {
      message: message,
      type: "badge"
    })
  end
end
