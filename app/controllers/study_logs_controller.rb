class StudyLogsController < ApplicationController
  before_action :authenticate_user!, except: [ :show, :index ]

  def new
    @study_log = StudyLog.new
    @study_genre = current_user.study_genres.last # ユーザーが選択した最新のジャンルを取得
    @study_reminder = current_user.study_reminders.last
  
    # ユーザーがジャンルを選択していない場合
    if @study_genre.nil?
      flash[:alert] = "ジャンルを先に設定してください"
      redirect_to new_study_genre_path # ジャンルを設定するページにリダイレクト
    else
      @study_log.study_genre_id = @study_genre.id # ジャンルIDを設定
    end
  end

  def create
    @study_log = current_user.study_logs.new(study_log_params) # ここで@study_logを初期化
    @study_genre = StudyGenre.find_by(id: params[:study_log][:study_genre_id]) || current_user.study_genres.last

    if @study_genre.nil?
      flash.now[:alert] = "指定された学習ジャンルが見つかりませんでした。"
      render :new, status: :unprocessable_entity and return
    end

    # ユーザーが選択したジャンルを UserStudyGenre テーブルに保存
    UserStudyGenre.find_or_create_by(user: current_user, study_genre: @study_genre)

    # 学習記録を保存
    if @study_log.save
      # バッジの割り当て
      StudyBadgeService.new(current_user).assign_first_study_log_badge

      tweet_text = URI.encode_www_form_component(
        "学習記録！\n『学習日: #{@study_log.date.strftime('%Y-%m-%d')}』\n『学習ジャンル: #{@study_genre.name}』\n『学習内容: #{@study_log.content}』\n『感想: #{@study_log.text}』\n#ProgramRoutineMate"
      )

      # 成功時のリダイレクト
      redirect_to study_logs_path(tweet_text: tweet_text), notice: "学習記録を作成しました。"
    else
      flash.now[:alert] = "学習記録を作成できませんでした。"
      render :new, status: :unprocessable_entity
    end
  end


def edit
  @study_log = current_user.study_logs.find(params[:id])
  @study_genre = @study_log.study_genre || current_user.study_genres.last # もしstudy_logにジャンルが設定されていなければ、ユーザーの最新ジャンルを設定
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
    study_log.destroy
    redirect_to study_logs_path, notice: "学習記録の削除をしました。"
  end

  def index
    @q = StudyLog.ransack(params[:q])
    @q.study_genre_id_eq = params[:study_genre_id] if params[:study_genre_id].present? # ジャンルIDの検索条件を追加

    @study_logs = @q.result(distinct: true).includes(:user).order(created_at: :asc).page(params[:page])


    @ranking = User.studied_logs_days_ranking.limit(3)



    @study_logs_for_js = current_user ? current_user.study_logs.where.not(date: nil).map { |log| { date: log.date.to_date, total: log.try(:total) || 0 } } : []

    @study_genres = StudyGenre.all # ジャンルのリストを取得
  end


  def autocomplete
    @q = StudyLog.ransack(params[:q])
    @study_logs = @q.result(distinct: true).limit(10)
    render json: @study_logs.as_json(only: [ :content ])
  end

  def ranking
    @ranking = User.studied_logs_days_ranking
  end

  def show
    @study_log = StudyLog.find(params[:id])
    @learning_comment = LearningComment.new
    @learning_comments = @study_log.learning_comments.includes(:user).order(created_at: :desc)
  end

  private

  def study_log_params
    params.require(:study_log).permit(:content, :text, :image, :image_cache, :date, :study_genre_id, :study_reminder_id, :count)
  end
end
