class StudyLogsController < ApplicationController
  def new
    @study_log = StudyLog.new
  end

  def create
    @study_log = StudyLog.new(study_log_params)
    if @study_log.save
      redirect_to study_logs_path
    else
      render :new
    end
  end

  def edit
    @study_log
  end

  def index
    @study_logs = StudyLog.all
  end

  private

  def study_log_params
    params.require(:study_log).permit(:content, :hour, :text)
  end
end
