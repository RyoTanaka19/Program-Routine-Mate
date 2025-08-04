class LikeNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_log_id, liker_user_id)
    study_log = StudyLog.includes(:user).find(study_log_id)
    liker = User.find(liker_user_id)
    owner = study_log.user

    # 自分の学習記録には「いいね」を送れないため、早期リターンする
    return if liker.id == owner.id

    message = build_like_message(liker, study_log)
    broadcast_notification(owner.id, message)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "LikeNotificationJob failed: StudyLog ID: #{study_log_id}, User ID: #{liker_user_id}. Error: #{e.message}"
  end

  private

  def build_like_message(liker, study_log)
    safe_content = ActionController::Base.helpers.strip_tags(study_log.content).truncate(20)
    liker_name = liker.name.presence || I18n.t("defaults.anonymous")
    safe_content = safe_content.presence || I18n.t("defaults.no_content")

    # i18n を使ってメッセージを構築
    I18n.t("like_notification.message", liker_name: liker_name, content: safe_content)
  end

  def broadcast_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", {
      message: message,
      type: "like",
      sender_id: liker.id,
      study_log_id: study_log.id
    })
  end
end
