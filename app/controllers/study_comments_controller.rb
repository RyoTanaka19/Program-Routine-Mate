class StudyCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log, only: [ :create ]
  before_action :set_study_comment, only: [ :edit, :update, :destroy ]

  def create
    @study_comment = current_user.study_comments.build(create_params)
    @study_comment.study_log = @study_log

    if @study_comment.save
      flash[:notice] = t("study_comments.created")
      CommentNotificationJob.perform_later(@study_comment.id) if @study_comment.study_log.user != current_user

      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to @study_log, notice: t("study_comments.created") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error }
        format.html {
          @study_comments = @study_log.study_comments.includes(:user)
          render "study_logs/show", status: :unprocessable_entity
        }
      end
    end
  end

  def destroy
    if @study_comment.destroy
      flash[:notice] = t("study_comments.destroyed")
      respond_to do |format|
        format.turbo_stream { render :destroy }
        format.html { redirect_to @study_comment.study_log, notice: t("study_comments.destroyed") }
      end
    else
      flash[:alert] = t("study_comments.destroy_failed")
      respond_to do |format|
        format.turbo_stream { render :destroy_error }
        format.html { redirect_to @study_comment.study_log, alert: t("study_comments.destroy_failed") }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream { render :edit }
      format.html { redirect_to @study_comment.study_log }
    end
  end

  def update
    if @study_comment.update(update_params)
      flash[:notice] = t("study_comments.updated")
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to @study_comment.study_log, notice: t("study_comments.updated") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update_error }
        format.html {
          render :edit, status: :unprocessable_entity
        }
      end
    end
  end

  private

  def set_study_log
    @study_log = StudyLog.find(params[:study_log_id])
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: t("study_comments.not_found_study_log")
  end

  def set_study_comment
    @study_comment = current_user.study_comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: t("study_comments.not_found_study_comment")
  end

  def create_params
    params.require(:study_comment).permit(:text, :study_log_id)
  end

  def update_params
    params.require(:study_comment).permit(:text)
  end
end
