class StudyLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log
  before_action :set_study_like, only: [ :destroy ]

  def create
    if @study_log.study_likes.exists?(user: current_user)
      redirect_to @study_log, alert: t("study_likes.already_liked")
      return
    end

    study_like = @study_log.study_likes.build(user: current_user)

    if study_like.save
      LikeNotificationJob.perform_later(@study_log.id, current_user.id)
      respond_to do |format|
        format.html do
          flash[:notice] = t("!study_likes.created")
          redirect_to @study_log
        end
        format.turbo_stream do
          flash.now[:notice] = t("study_likes.created")
          render :create
        end
      end
    else
      redirect_to @study_log, alert: t("study_likes.failed")
    end
  end

  def destroy
    @study_like.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = t("study_likes.destroyed")
        redirect_to @study_log
      end
      format.turbo_stream do
        flash.now[:notice] = t("study_likes.destroyed")
        render :destroy
      end
    end
  end

  private

  def set_study_log
    @study_log = StudyLog.find(params[:study_log_id])
  end

  def set_study_like
    @study_like = @study_log.study_likes.find_by!(user: current_user)
  end
end
