class StudyBadgeService
  def initialize(user)
    @user = user
  end

  # バッジの付与を一元管理するメソッド
  def assign_badges
    # それぞれのストリークに応じたバッジを付与
    assign_streak_badges
    assign_first_study_log_badge # 初回学習記録のバッジ
  end

  private

  # 初回学習記録のバッジを付与
  def assign_first_study_log_badge
    return if @user.study_logs.count > 1

    badge = StudyBadge.find_or_create_by(
      name: "初めての学習記録達成!",
      description: "初めて学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon.png"
    )

    unless @user.study_badges.exists?(badge.id)
      @user.user_study_badges.create(study_badge: badge, earned_at: Time.current)
      BadgeNotificationJob.perform_later(badge.id, @user.id)
    end
  end

  # ストリークに応じたバッジを付与
  def assign_streak_badges
    [1, 2, 3, 5, 7].each do |streak|
      assign_streak_badge(streak)
    end
  end

  def assign_streak_badge(streak)
    badge_info = {
      1 => { name: "初めての学習記録達成!", description: "初めて学習記録を投稿したユーザーに付与されるバッジ", icon: "icon.png" },
      2 => { name: "2日学習記録達成!", description: "異なる2日で学習記録を投稿したユーザーに付与されるバッジ", icon: "icon2.png" },
      3 => { name: "3日学習記録達成!", description: "異なる3日で学習記録を投稿したユーザーに付与されるバッジ", icon: "icon3.png" },
      5 => { name: "5日学習記録達成!", description: "異なる5日で学習記録を投稿したユーザーに付与されるバッジ", icon: "icon4.png" },
      7 => { name: "7日学習記録達成!", description: "異なる7日で学習記録を投稿したユーザーに付与されるバッジ", icon: "mate.png" }
    }[streak]

    return unless badge_info && logged_days_count >= streak

    badge = StudyBadge.find_or_create_by(
      name: badge_info[:name],
      description: badge_info[:description],
      icon: badge_info[:icon]
    )

    unless @user.study_badges.exists?(badge.id)
      @user.user_study_badges.create(study_badge: badge, earned_at: Time.current)
      BadgeNotificationJob.perform_later(badge.id, @user.id)
    end
  end

  # 学習記録を投稿したユニークな日数をカウント
  def logged_days_count
    @user.study_logs.distinct.count(:date)
  end
end
