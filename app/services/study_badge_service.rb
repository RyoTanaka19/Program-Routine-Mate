class StudyBadgeService
  def initialize(user)
    @user = user
  end

  def assign_first_study_log_badge
    assign_badge_if_not_earned(
      name: "初めての学習記録達成!",
      description: "初めて学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon.png"
    )
  end

  def assign_two_days_streak_badge
    return unless logged_days_count >= 2

    assign_badge_if_not_earned(
      name: "2日学習記録達成!",
      description: "異なる2日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon2.png"
    )
  end

  def assign_three_days_streak_badge
    return unless logged_days_count >= 3

    assign_badge_if_not_earned(
      name: "3日学習記録達成!",
      description: "異なる3日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon3.png"
    )
  end

  # ✅ 新規追加: 5日学習記録
  def assign_five_days_streak_badge
    return unless logged_days_count >= 5

    assign_badge_if_not_earned(
      name: "5日学習記録達成!",
      description: "異なる5日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon4.png"
    )
  end

  # ✅ 新規追加: 7日学習記録
  def assign_seven_days_streak_badge
    return unless logged_days_count >= 7

    assign_badge_if_not_earned(
      name: "7日学習記録達成!",
      description: "異なる7日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "mate.png"
    )
  end

  private

  def logged_dates
    @user.study_logs.where.not(date: nil).distinct.pluck(:date).uniq
  end

  def logged_days_count
    logged_dates.size
  end

  def assign_badge_if_not_earned(name:, description:, icon:)
    badge = StudyBadge.find_or_create_by(
      name: name,
      description: description,
      icon: icon
    )

    unless @user.study_badges.exists?(badge.id)
      @user.user_study_badges.create(study_badge: badge, earned_at: Time.current)
      NotifyUserJob.perform_later(nil, nil, badge.id, @user.id)
    end
  end
end
