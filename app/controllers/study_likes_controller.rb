class StudyLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log
  before_action :set_study_like, only: [ :destroy ]

  def create
    @study_like = @study_log.study_likes.build(user: current_user)

    if @study_like.save
      LikeNotificationJob.perform_later(@study_log.id, current_user.id)
      @notice_message = "いいねしました！"
      respond_to do |format|
        format.html do
          flash[:notice] = @notice_message
          redirect_to study_logs_path
        end
        format.turbo_stream do
          flash.now[:notice] = @notice_message
          render :create
        end
      end
    else
      redirect_to study_logs_path, alert: "いいねできませんでした。"
    end
  end

  def destroy
    if @study_like
      @study_like.destroy
      @notice_message = "いいねを取り消しました。"
      respond_to do |format|
        format.html do
          flash[:notice] = @notice_message
          redirect_to study_logs_path
        end
        format.turbo_stream do
          flash.now[:notice] = @notice_message
          render :destroy
        end
      end
    else
      redirect_to study_logs_path, alert: "いいねが見つかりません。"
    end
  end

  private

  def set_study_log
    @study_log = StudyLog.find(params[:study_log_id])
  end

  def set_study_like
    @study_like = @study_log.study_likes.find_by(user: current_user)
  end
end
