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
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "LikeNotificationJob failed: #{e.message}"
  end

  private

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end
end
