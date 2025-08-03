module StudyLogsHelper
  def display_study_time(seconds)
    return t("study_log.helper.unset") if seconds.blank?

    minutes = seconds / 60
    secs = seconds % 60

    if minutes > 0
      "#{minutes}#{t('study_log.helper.minutes')}#{secs}#{t('study_log.helper.seconds')}"
    else
      "#{secs}#{t('study_log.helper.seconds')}"
    end
  end
end
