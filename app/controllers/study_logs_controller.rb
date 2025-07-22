class StudyLogsController < ApplicationController
  before_action :authenticate_user!, except: [ :show, :index, :autocomplete ]

 def new
  @study_genre = current_user.study_genres.last
  @study_reminder = current_user.study_reminders.last

  if @study_genre.nil?
    flash[:alert] = "ジャンルを先に設定してください"
    redirect_to new_study_genre_path and return
  end

  @study_log = StudyLog.new(
    study_genre_id: @study_genre.id,
    study_reminder_id: @study_reminder&.id
  )
  end


  def create
    @study_genre = StudyGenre.find_by(id: params.dig(:study_log, :study_genre_id)) || current_user.study_genres.last

    if @study_genre.nil?
     @study_log = current_user.study_logs.new(study_log_params)
     @study_reminder = current_user.study_reminders.last

      respond_to do |format|
       format.html do
          flash.now[:alert] = "指定された学習ジャンルが見つかりませんでした。"
          render :new, status: :unprocessable_entity
        end
        format.json do
          render json: { success: false, errors: [ "指定された学習ジャンルが見つかりませんでした。" ] }, status: :unprocessable_entity
        end
      end
      return
    end

    @study_log = current_user.study_logs.new(study_log_params)
    @study_log.study_genre_id ||= @study_genre.id
    @study_reminder = current_user.study_reminders.last

    UserStudyGenre.find_or_create_by(user: current_user, study_genre: @study_genre)

    respond_to do |format|
      if @study_log.save
        notice = "学習記録が作成されました！"
        notice += "（投稿時刻が学習時間外のため、学習時間は記録されませんでした）" if @study_log.total.nil?

        format.html { redirect_to new_study_log_study_challenge_path(@study_log), notice: notice }
        format.json { render json: { success: true, contribution_graph: [] } }  # ここを空配列に変更
      else
        format.html do
         flash.now[:alert] = "学習記録の作成に失敗しました。"
         render :new, status: :unprocessable_entity
        end
        format.json do
          render json: { success: false, errors: @study_log.errors.full_messages }, status: :unprocessable_entity
        end
      end
   end
  end


  def edit
    @study_log = current_user.study_logs.find(params[:id])

    @study_genre = @study_log.study_genre || current_user.study_genres.last
  end


  def update
   @study_log = current_user.study_logs.find(params[:id])
    @study_genre = @study_log.study_genre


    @study_log.remove_image! if params.dig(:study_log, :remove_image) == "1"

    respond_to do |format|
      if @study_log.update(study_log_params)
        format.html { redirect_to study_logs_path, notice: "学習記録の変更をしました。" }
        format.json { render json: { success: true, contribution_graph: [] } }
      else
        format.html do
         flash.now[:alert] = "学習記録の変更に失敗しました。"
          render :edit, status: :unprocessable_entity
        end
        format.json do
          render json: { success: false, errors: @study_log.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end




  def destroy
    study_log = current_user.study_logs.find(params[:id])
    study_log.destroy
    redirect_to study_logs_path, notice: "学習記録の削除をしました。"
  end

  def index
    params[:q] ||= {}
    params[:q][:study_genre_id_eq] = params[:study_genre_id] if params[:study_genre_id].present?

    @q = StudyLog.ransack(params[:q])

    @study_logs = @q.result(distinct: true).includes(:user).order(created_at: :asc).page(params[:page])

    @contribution_graph = if current_user
      current_user.study_logs.where.not(date: nil).map do |log|
        {
         date: log.date.to_date,
          total: log.total.to_f
        }
      end
    else
    []
    end

   @study_genres = StudyGenre.all
  end



  def autocomplete
    return render json: [] if params[:q].blank?

    @q = StudyLog.ransack(params[:q])

    begin
      @study_logs = @q.result(distinct: true).limit(10)
      render json: @study_logs.as_json(only: [ :content ])
    rescue => e
      Rails.logger.error "[AutocompleteError] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { error: "検索中にエラーが発生しました。" }, status: 500
    end
  end

  def ranking
    @ranking = User.studied_logs_days_ranking
  end


  def show
    @study_log = StudyLog.find(params[:id])
    @study_comment = StudyComment.new
    @study_comments = @study_log.study_comments.includes(:user).order(created_at: :desc)
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
    params.require(:study_log).permit(:content, :text, :image, :image_cache, :date, :study_genre_id, :study_reminder_id, :count, :remove_image)
  end


  def prepare_meta_tags(study_log)
    image_url = if study_log.image.present?
                study_log.image.url.to_s
    else
                "#{request.base_url}/images/ogp.png?text=#{CGI.escape(study_log.content)}"
    end

    set_meta_tags og: {
                  site_name: "ProgramRoutineMate",
                  title: study_log.content,
                  description: "プログラミング学習記録の投稿",
                  type: "website",
                  url: request.original_url,
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
