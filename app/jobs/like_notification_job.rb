class LikeNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_log_id, liker_user_id)
    study_log = StudyLog.find_by(id: study_log_id)
    liker = User.find_by(id: liker_user_id)

    if study_log.nil? || liker.nil?
      Rails.logger.warn "LikeNotificationJob failed: StudyLog or Liker not found. study_log_id: #{study_log_id}, liker_user_id: #{liker_user_id}"
      return
    end

    owner = study_log.user
    return if liker.id == owner.id # 自分への通知はスキップ

    # 学習記録の内容をタグを取り除いて、20文字でトリミング
    safe_content = ActionController::Base.helpers.strip_tags(study_log.content).truncate(20, omission: "")
    liker_name = liker.name.presence || I18n.t("defaults.anonymous")
    safe_content = safe_content.presence || I18n.t("defaults.no_content")

    # i18nメッセージ作成
    message = I18n.t("like_notification.message", liker_name: liker_name, content: safe_content)

    # コメント通知と同様に送信
    broadcast_notification(owner.id, message)
  rescue => e
    Rails.logger.warn "LikeNotificationJob failed: #{e.message}"
    Rails.logger.warn e.backtrace.join("\n")
  end

  private

  def broadcast_notification(user_id, message, broadcast_service = ActionCable.server)
    broadcast_service.broadcast("notification_channel_#{user_id}", { message: message })
  end
end
