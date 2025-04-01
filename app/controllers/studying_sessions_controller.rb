class StudyingSessionsController < ApplicationController
  def new
    @studying_session = StudyingSession.new
  end

  def create
    @studying_session = StudyingSession.new(studying_session_params)
    if @studying_session.save
      # 学習開始時間に通知を送るジョブをスケジュール
      NotifyLineJob.perform_later(@studying_session.id, :start_time)

      # 学習終了時間に通知を送るジョブをスケジュール
      NotifyLineJob.perform_later(@studying_session.id, :end_time)

      redirect_to studying_sessions_path, notice: '学習時間が保存され、通知が設定されました'
    else
      render :new
    end
  end

  private

  def studying_session_params
    params.require(:studying_session).permit(:start_time, :end_time)
  end
end

