class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log
  before_action :set_like, only: [ :destroy ]

  def create
    @like = @study_log.likes.build(user: current_user)

    if @like.save
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
    if @like
      @like.destroy
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

  def set_like
    @like = @study_log.likes.find_by(user: current_user)
  end
end
