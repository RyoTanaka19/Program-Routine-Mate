class StudyBadgeService
  BADGE_INFOS = {
    1 => {
      name: "初めての学習記録達成!",
      description: "初めて学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon.png"
    },
    2 => {
      name: "2日学習記録達成!",
      description: "異なる2日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon2.png"
    },
    3 => {
      name: "3日学習記録達成!",
      description: "異なる3日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon3.png"
    },
    5 => {
      name: "5日学習記録達成!",
      description: "異なる5日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "icon5.png"
    },
    7 => {
      name: "7日学習記録達成!",
      description: "異なる7日で学習記録を投稿したユーザーに付与されるバッジ",
      icon: "mate.png"
    }
  }.freeze

  def initialize(user)
    @user = user
  end

  # バッジの付与を一元管理するメソッド
  def assign_badges
    assign_streak_badges
    assign_first_study_log_badge
  end

  private

  def assign_first_study_log_badge
    # 投稿が1件以上ある場合のみ処理
    return unless @user.study_logs.exists?

    badge_info = BADGE_INFOS[1]

    assign_badge(badge_info)
  end

  # ストリークに応じたバッジを付与
  def assign_streak_badges
    [ 1, 2, 3, 5, 7 ].each do |streak|
      assign_streak_badge(streak)
    end
  end

  def assign_streak_badge(streak)
    badge_info = BADGE_INFOS[streak]
    return unless badge_info
    return unless logged_days_count >= streak

    assign_badge(badge_info)
  end

  # バッジ付与の共通処理（例外処理含む）
  def assign_badge(badge_info)
    badge = nil

    begin
      badge = StudyBadge.find_or_create_by!(
        name: badge_info[:name],
        description: badge_info[:description],
        icon: badge_info[:icon]
      )
    rescue => e
      Rails.logger.error("[StudyBadgeService] バッジ取得・作成エラー: #{e.message}")
      return
    end

    # 重複付与防止
    if @user.study_badges.exists?(badge.id)
      return
    end

    begin
      @user.user_study_badges.create!(study_badge: badge, earned_at: Time.current)
      BadgeNotificationJob.perform_later(badge.id, @user.id)
    rescue => e
      Rails.logger.error("[StudyBadgeService] バッジ付与または通知ジョブエラー: #{e.message}")
    end
  end

  # 学習記録を投稿したユニークな日数をカウント
  def logged_days_count
    @user.study_logs.distinct.count(:date)
  end
end
