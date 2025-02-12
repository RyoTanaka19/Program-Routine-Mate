class StudyLogsController < ApplicationController
  before_action :authenticate_user!

  def new
    @study_log = StudyLog.new
  end

  def create
    @study_log = current_user.study_logs.build(study_log_params)
    if @study_log.save
      redirect_to study_logs_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @study_log = current_user.study_logs.find(params[:id])
  end

  def update
    @study_log = current_user.study_logs.find(params[:id])
    if @study_log.update(study_log_params)
      redirect_to study_logs_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    study_log = current_user.study_logs.find(params[:id])
    study_log.destroy!
    redirect_to study_logs_path
  end

  def index
    @study_logs = StudyLog.includes(:user).order(created_at: :asc).all
  end

  def show
    @study_log = StudyLog.find(params[:id])
    @learning_comment = LearningComment.new
    @learning_comments = @study_log.learning_comments.includes(:user).order(created_at: :desc)
  end

  private


  def study_log_params
    params.require(:study_log).permit(:content, :hour, :text, :image, :image_cache)
  end
end
