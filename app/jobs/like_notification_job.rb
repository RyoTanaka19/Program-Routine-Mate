class LikeNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_log_id, liker_user_id)
    study_log = StudyLog.find(study_log_id)
    liker = User.find(liker_user_id)
    owner = study_log.user

    return if liker.id == owner.id

    safe_content = ActionController::Base.helpers.strip_tags(study_log.content).truncate(20)
    message = "#{liker.name}さんがあなたの学習記録「#{safe_content}」にいいねしました！"

    broadcast_browser_notification(owner.id, message)
    send_line_notification(owner, message)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "LikeNotificationJob failed: #{e.message}"
  end

  private

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end

  # LINE通知を送信するメソッド
  def send_line_notification(user, message)
    return if user.uid.blank?  # ユーザーのLINE IDが無ければ通知しない

    client = LINE_BOT_API  # LINE APIのクライアントインスタンス
    begin
      client.push_message(user.uid, { type: "text", text: message })  # LINE通知送信
    rescue StandardError => e
      Rails.logger.error("LINE通知送信エラー: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end
end
