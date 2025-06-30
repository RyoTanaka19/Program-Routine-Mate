class StudyBadgeService
  def initialize(user)
    @user = user
  end

  def assign_first_study_log_badge
    badge = StudyBadge.find_or_create_by(
      name: "初めての学習記録",
      description: "初めて学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon.png"
    )

    unless @user.study_badges.exists?(badge.id)
      @user.user_study_badges.create(study_badge: badge, earned_at: Time.current)
      NotifyLineJob.perform_later(nil, nil, badge.id, @user.id)
    end
  end
end
