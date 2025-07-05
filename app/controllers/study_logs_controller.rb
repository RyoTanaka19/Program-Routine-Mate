class StudyLogsController < ApplicationController
  before_action :authenticate_user!, except: [ :show, :index, :autocomplete ]

  def new
    @study_log = StudyLog.new
    @study_genre = current_user.study_genres.last
    @study_reminder = current_user.study_reminders.last


    if @study_genre.nil?
      flash[:alert] = "ジャンルを先に設定してください"
      redirect_to new_study_genre_path
    else
      @study_log.study_genre_id = @study_genre.id
    end
  end


  def create
    @study_log = current_user.study_logs.new(study_log_params)
    @study_genre = StudyGenre.find_by(id: params[:study_log][:study_genre_id]) || current_user.study_genres.last

    if @study_genre.nil?
      flash.now[:alert] = "指定された学習ジャンルが見つかりませんでした。"
      render :new, status: :unprocessable_entity and return
    end


    user_study_genre = UserStudyGenre.find_or_create_by(user: current_user, study_genre: @study_genre)

    if @study_log.save
      notice = "学習記録が作成されました！"
      notice += "（投稿時刻が学習時間外のため、学習時間は記録されませんでした）" if @study_log.total.nil?
      redirect_to new_study_log_study_challenge_path(@study_log), notice: notice
    else
       flash.now[:alert] = "学習記録の作成に失敗しました。"
        render :new, status: :unprocessable_entity
    end
  end


  def edit
    @study_log = current_user.study_logs.find(params[:id])

    @study_genre = @study_log.study_genre || current_user.study_genres.last
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
   @q.study_genre_id_eq = params[:study_genre_id] if params[:study_genre_id].present?
   @study_logs = @q.result(distinct: true).includes(:user).order(created_at: :asc).page(params[:page])

    @study_logs_for_js = current_user ? current_user.study_logs.where.not(date: nil).map { |log| { date: log.date.to_date, total: log.try(:total) || 0 } } : []

    @study_genres = StudyGenre.all
  end

  def autocomplete
    @q = StudyLog.ransack(params[:q])

    if params.dig(:q, :study_genre_name_eq).present?
      @q.study_genre_name_eq = params.dig(:q, :study_genre_name_eq)
    end

    begin
      @study_logs = @q.result(distinct: true).limit(10)

      render json: @study_logs.as_json(only: [ :content ])

    rescue => e
      render json: { error: "検索中にエラーが発生しました: #{e.message}" }, status: 500
    end
  end

  def ranking
    @ranking = User.studied_logs_days_ranking
  end


  def show
    @study_log = StudyLog.find(params[:id])
    @learning_comment = LearningComment.new
    @learning_comments = @study_log.learning_comments.includes(:user).order(created_at: :desc)
    prepare_meta_tags(@study_log)
  end

  def logs_by_date
  date = Date.parse(params[:date]) rescue nil

  if date.nil?
    render json: { error: "無効な日付です" }, status: :bad_request and return
  end

  study_logs = current_user.study_logs.where(date: date).includes(:study_genre).order(created_at: :asc)

  render json: study_logs.as_json(
    only: [ :id, :content, :text, :created_at ],
    include: { study_genre: { only: :name } }
  )
end

  private

  def study_log_params
    params.require(:study_log).permit(:content, :text, :image, :image_cache, :date, :study_genre_id, :study_reminder_id, :count)
  end


  def prepare_meta_tags(study_log)
    image_url = "#{request.base_url}/images/ogp.png?text=#{CGI.escape(study_log.content)}"
    set_meta_tags og: {
                        site_name: "ProgramRoutineMate",
                        title: study_log.content,
                        description: "プログラミング学習記録の投稿",
                        type: "website",
                        url: "https://program-routine-mate.com/",
                        image: image_url,
                        locale: "ja-JP"
                      },
                      twitter: {
                        card: "summary_large_image",
                        site: "@58a_tanaka_ryo",
                        image: image_url
                      }
  end
end
