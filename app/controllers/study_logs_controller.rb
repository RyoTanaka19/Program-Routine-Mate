class StudyLogsController < ApplicationController
  before_action :authenticate_user!, except: [ :show, :index, :autocomplete ]
  before_action :set_latest_study_reminder, only: [ :new, :create ]
  before_action :set_study_log, only: [ :edit, :update, :destroy ]
  before_action :set_study_genre_from_log_or_user, only: [ :new, :edit ]
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def new
    if @study_genre.nil?
      redirect_to new_study_genre_path, alert: t("study_logs.alerts.set_genre_first")
      return
    end

    @study_log = StudyLog.new(
      study_genre_id: @study_genre.id,
      study_reminder_id: @study_reminder&.id
    )
  end

  def create
    @study_genre = find_or_last_study_genre

    if @study_genre.nil?
      @study_log = current_user.study_logs.new(study_log_params)
      respond_to do |format|
        format.html do
          flash.now[:alert] = t("study_logs.alerts.genre_not_found")
          render :new, status: :unprocessable_entity
        end
        format.json { render_json_errors(@study_log, [ t("study_logs.alerts.genre_not_found") ]) }
      end
      return
    end

    @study_log = current_user.study_logs.new(study_log_params.merge(study_genre_id: @study_genre.id))
    UserStudyGenre.find_or_create_by(user: current_user, study_genre: @study_genre)

    respond_to do |format|
      if @study_log.save
        notice = t("study_logs.notices.created")
        notice += t("study_logs.notices.out_of_study_time") if @study_log.total_study_time.nil?

        format.html { redirect_to new_study_log_study_challenge_path(@study_log), notice: notice }
        format.json { render json: { success: true, contribution_graph: [] } }
      else
        format.html do
          flash.now[:alert] = t("study_logs.alerts.creation_failed")
          render :new, status: :unprocessable_entity
        end
        format.json { render_json_errors(@study_log) }
      end
    end
  end

  def edit
    # @study_genre は before_action でセット済み
  end

  def update
    @study_genre = @study_log.study_genre
    @study_log.remove_image! if params.dig(:study_log, :remove_image) == "1"

    respond_to do |format|
      if @study_log.update(study_log_params)
        format.html { redirect_to study_logs_path, notice: t("study_logs.notices.updated") }
        format.json { render json: { success: true, contribution_graph: [] } }
      else
        format.html do
          flash.now[:alert] = t("study_logs.alerts.update_failed")
          render :edit, status: :unprocessable_entity
        end
        format.json { render_json_errors(@study_log) }
      end
    end
  end

  def destroy
    @study_log.destroy
    redirect_to study_logs_path, notice: t("study_logs.notices.destroyed")
  end

  def index
    @q = StudyLog.ransack(build_search_params)
    @study_logs = @q.result(distinct: true)
                    .includes(:user)
                    .order(created_at: :desc)
                    .page(params[:page])
    @contribution_graph = current_user&.contribution_graph_data || []
    @study_genres = StudyGenre.all
  end

  def autocomplete
    return render json: [] if params[:q].blank?

    @q = StudyLog.ransack(params[:q])
    begin
      @study_logs = @q.result(distinct: true).limit(10)
      render json: @study_logs.as_json(only: [ :content ])
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error "[AutocompleteError] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { error: t("study_logs.alerts.search_error") }, status: 500
    end
  end

  def show
    @study_log = StudyLog.find(params[:id])
    @study_comment = StudyComment.new
    @study_comments = @study_log.study_comments.includes(:user).order(created_at: :desc)
    prepare_meta_tags(@study_log)
  end

  def logs_by_date
    begin
      date = Date.parse(params[:date])
    rescue ArgumentError
      render json: { error: t("study_logs.alerts.invalid_date") }, status: :bad_request
      return
    end

    study_logs = current_user.study_logs.where(date: date).includes(:study_genre).order(created_at: :asc)

    render json: study_logs.as_json(
      only: [ :id, :content, :text, :created_at ],
      include: { study_genre: { only: :name } }
    )
  end

  private

  def set_latest_study_reminder
    @study_reminder = current_user.study_reminders.last
  end

  def set_study_log
    @study_log = current_user.study_logs.find(params[:id])
  end

  def set_study_genre_from_log_or_user
    @study_genre = @study_log&.study_genre || current_user.study_genres.last
  end

  def find_or_last_study_genre
    StudyGenre.find_by(id: params.dig(:study_log, :study_genre_id)) || current_user.study_genres.last
  end

  def render_json_errors(record, custom_messages = nil)
    render json: { success: false, errors: custom_messages || record.errors.full_messages }, status: :unprocessable_entity
  end

  def record_not_found
    flash[:alert] = t("study_logs.alerts.record_not_found")
    redirect_to study_logs_path
  end

  def build_search_params
    search_params = params[:q] || {}
    search_params[:study_genre_id_eq] = params[:study_genre_id] if params[:study_genre_id].present?
    search_params
  end

  def study_log_params
    params.require(:study_log).permit(:content, :text, :image, :image_cache, :date, :study_genre_id, :study_reminder_id, :count, :remove_image, :total_study_time)
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
                    description: t("study_logs.meta.description"),
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
