class StudyBadgeService
  BADGE_INFOS = {
    1 => {
      name_key: "study_badges.names.first_study_log",
      description_key: "study_badges.descriptions.first_study_log",
      icon: "icon.png" # 修正：シングルクオートを削除し、正しい画像名に修正
    },
    2 => {
      name_key: "study_badges.names.two_days",
      description_key: "study_badges.descriptions.two_days",
      icon: "badge2.png"
    },
    3 => {
      name_key: "study_badges.names.three_days",
      description_key: "study_badges.descriptions.three_days",
      icon: "badge3.png"
    },
    5 => {
      name_key: "study_badges.names.five_days",
      description_key: "study_badges.descriptions.five_days",
      icon: "badge5.png"
    },
    7 => {
      name_key: "study_badges.names.seven_days",
      description_key: "study_badges.descriptions.seven_days",
      icon: "mate.png"
    }
  }.freeze

  def initialize(user)
    @user = user
  end

  def assign_badges
    assign_streak_badges
    assign_first_study_log_badge
  end

  private

  def assign_first_study_log_badge
    return unless @user.study_logs.exists?

    badge_info = BADGE_INFOS[1]
    assign_badge(badge_info)
  end

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

  def assign_badge(badge_info)
    badge = nil

    begin
      badge = StudyBadge.find_or_create_by!(
        name: I18n.t(badge_info[:name_key]),
        description: I18n.t(badge_info[:description_key]),
        icon: badge_info[:icon]
      )
    rescue StandardError => e
      Rails.logger.error("[StudyBadgeService] バッジ取得・作成エラー: #{e.message}")
      return
    end

    return if @user.user_study_badges.exists?(study_badge_id: badge.id)

    begin
      @user.user_study_badges.create!(study_badge: badge, earned_at: Time.current)
      BadgeNotificationJob.perform_later(badge.id, @user.id)
    rescue StandardError => e
      Rails.logger.error("[StudyBadgeService] バッジ付与または通知ジョブエラー: #{e.message}")
    end
  end

  def logged_days_count
    @user.study_logs.distinct.count(:date)
  end
end
