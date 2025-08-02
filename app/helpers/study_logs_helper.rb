module StudyLogsHelper
  def display_study_time(seconds)
    return "未設定" if seconds.blank?

    minutes = seconds / 60
    secs = seconds % 60
    minutes > 0 ? "#{minutes}分#{secs}秒" : "#{secs}秒"
  end
end
