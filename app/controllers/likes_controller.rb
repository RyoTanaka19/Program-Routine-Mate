class LikesController < ApplicationController
  def create
    @study_log = StudyLog.find(params[:study_log_id])
    @like = @study_log.likes.build(user: current_user)
    if @like.save
      redirect_to study_logs_path, notice: "いいねしました！"
    else
      redirect_to study_logs_path, alert: "いいねできませんでした。"
    end
  end

  def destroy
    @study_log = StudyLog.find(params[:study_log_id])
    @like = @study_log.likes.find_by(user: current_user)
    if @like
      @like.destroy
      redirect_to study_logs_path, notice: "いいねを取り消しました。"
    else
      redirect_to study_logs_path, alert: "いいねが見つかりません。"
    end
  end
end
