class LikeNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_log_id, liker_user_id)
    study_log = StudyLog.includes(:user).find(study_log_id)
    liker = User.find(liker_user_id)
    owner = study_log.user

    # 自分の学習記録には「いいね」を送れないため、早期リターンする
    return if liker.id == owner.id

    message = build_like_message(liker, study_log)

    # 必要な情報をすべて引数で渡す
    broadcast_notification(owner.id, message, liker.id, study_log.id)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "LikeNotificationJob failed: StudyLog ID: #{study_log_id}, User ID: #{liker_user_id}. Error: #{e.message}"
  end

  private

  def build_like_message(liker, study_log)
    safe_content = ActionController::Base.helpers.strip_tags(study_log.content).truncate(20)
    liker_name = liker.name.presence || I18n.t("defaults.anonymous")
    safe_content = safe_content.presence || I18n.t("defaults.no_content")

    I18n.t("like_notification.message", liker_name: liker_name, content: safe_content)
  end

  # 修正ポイント：メソッド内で参照しないで、引数で渡す
  def broadcast_notification(user_id, message, sender_id, study_log_id)
    ActionCable.server.broadcast("notification_channel_#{user_id}", {
      message: message,
      type: "like",
      sender_id: sender_id,
      study_log_id: study_log_id
    })
  end
end
