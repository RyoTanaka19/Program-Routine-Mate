class StudyLogsController < ApplicationController
  before_action :authenticate_user!, except: [ :show, :index ]

  def new
    @study_log = StudyLog.new
  end

  def create
    @study_log = current_user.study_logs.build(study_log_params)

    if @study_log.save
      StudyBadgeService.new(current_user).assign_first_study_log_badge
      redirect_to study_logs_path, notice: "学習記録を作成しました。"
    else
      flash.now[:alert] = "学習記録を作成できませんでした。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @study_log = current_user.study_logs.find(params[:id])
  end

  def update
    @study_log = current_user.study_logs.find(params[:id])
    if @study_log.update(study_log_params)
      redirect_to study_logs_path, notice: "学習記録の変更をしました。"
    else
      flash.now[:alert] = "学習記録の変更に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    study_log = current_user.study_logs.find(params[:id])
    study_log.destroy!
    redirect_to study_logs_path, notice: "学習記録の削除をしました。"
  end

  def index
    @q = StudyLog.ransack(params[:q])
    @study_logs = @q.result(distinct: true).includes(:user).order(created_at: :asc)
    @ranking = User.studied_logs_days_ranking.limit(3)
  end

  def ranking
    # 投稿日数ランキングを取得
    @ranking = User.studied_logs_days_ranking  # ユーザーの投稿日数ランキング
  end

  def show
    @study_log = StudyLog.find(params[:id])
    @learning_comment = LearningComment.new
    @learning_comments = @study_log.learning_comments.includes(:user).order(created_at: :desc)
  end

  private

  def study_log_params
    params.require(:study_log).permit(:genre, :start_date, :end_date, :study_day, :start_time, :end_time, :content, :text, :image, :image_cache)
  end
end
