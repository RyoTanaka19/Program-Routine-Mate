class StudyGenresController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update ]

  def index
    raw_stats = StudyGenre
                  .joins(:study_logs)
                  .select("study_genres.name, COUNT(study_logs.id) AS post_count, COUNT(DISTINCT study_logs.user_id) AS user_count")
                  .group("study_genres.name")

    @genre_stats = raw_stats.map do |record|
      display_name = DISPLAY_NAME_MAP[record.name] || record.name

      {
        name: display_name,
        post_count: record.post_count,
        user_count: record.user_count
      }
    end.sort_by { |stat| -stat[:user_count] }
  end

  def new
    @study_genre = current_user.study_genres.new
    @study_genres = current_user.study_genres.order(created_at: :desc)
    @last_genre = @study_genres.first

    @has_21_days_of_logs = current_user.study_logs
                               .select("DATE(created_at)").distinct.count >= 21
  end

  def create
    unless can_create_new_genre?
      return add_flash_and_respond("新しいジャンルを設定する条件が満たされていません。", :respond_with_create_error)
    end

    if genre_name_exists?(study_genre_params[:name])
      return add_flash_and_respond("すでに設定しているジャンルは設定できません。", :respond_with_create_error)
    end

    @study_genre = current_user.study_genres.new(study_genre_params)

    if @study_genre.save
      respond_to do |format|
        format.html { redirect_to new_study_log_path(study_genre_id: @study_genre.id), notice: "ジャンルが設定されました。" }
        format.json { render json: { success: true, study_genre_id: @study_genre.id } }
      end
    else
      respond_with_create_error
    end
  end

  def edit
    @study_genre = current_user.study_genres.find(params[:id])
  end

  def update
    @study_genre = current_user.study_genres.find(params[:id])
    new_name = params[:study_genre][:name]

    if @study_genre.name == new_name
      return add_flash_and_respond("現在のジャンルでの更新はできません。", :respond_with_update_error)
    end

    if current_user.study_genres.exists?(name: new_name)
      return add_flash_and_respond("他で設定しているジャンルと同じ名前は設定できません。", :respond_with_update_error)
    end

    StudyGenre.transaction do
      # 二重チェック削除：ここは常に名前変更時の処理になるため条件不要に
      @study_genre.study_logs.update_all(study_genre_id: nil)
      unless @study_genre.update(study_genre_params)
        flash.now[:alert] = "ジャンルの更新に失敗しました。"
        raise ActiveRecord::Rollback
      end
    end

    if flash.now[:alert].present?
      respond_with_update_error
    else
      flash[:notice] = "ジャンルが更新されました。"
      redirect_to new_study_log_path(study_genre_id: @study_genre.id)
    end
  end

  def show
    @study_genre = StudyGenre.find_by(id: params[:id])

    if @study_genre.nil?
      flash[:alert] = "指定されたジャンルは見つかりません。"
      redirect_to study_genres_path
      return
    end

    @wikipedia_summary = begin
      WikipediaFetcher.fetch_summary(@study_genre.name)
    rescue StandardError => e
      Rails.logger.error("[WikipediaFetcher] Failed to fetch summary for #{@study_genre.name}: #{e.message}")
      nil
    end

    respond_to do |format|
      format.html
      format.json do
        if current_user.nil?
          render json: {}, status: :unauthorized
          return
        end

        logs_by_date = @study_genre.study_logs
                                   .where(user: current_user)
                                   .group("DATE(created_at)")
                                   .order("DATE(created_at)")
                                   .count

        logs_by_date_formatted = logs_by_date.transform_keys { |date| date.strftime("%Y-%m-%d") }
        render json: logs_by_date_formatted
      end
    end
  end

  private

  DISPLAY_NAME_MAP = {
    "PHP_(プログラミング言語)" => "PHP"
    # 今後他にあればここに追加可能
  }.freeze

  def can_create_new_genre?
    return true if current_user.study_genres.empty?

    last_genre = current_user.study_genres.order(created_at: :desc).first
    last_genre.present? && has_21_days_of_logs?(last_genre)
  end

  def genre_name_exists?(name)
    current_user.study_genres.exists?(name: name)
  end

  def has_21_days_of_logs?(genre)
    genre.study_logs.select("DATE(created_at)").distinct.count >= 21
  end

  def add_flash_and_respond(alert_message, method)
    flash.now[:alert] = alert_message
    send(method)
  end

  def respond_with_create_error
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages", partial: "shared/flash_messages") }
      format.json { render json: { success: false, errors: [ flash.now[:alert] ] }, status: :unprocessable_entity }
    end
  end

  def respond_with_update_error
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream { render "study_genres/update" }
    end
  end

  def study_genre_params
    params.require(:study_genre).permit(:name)
  end

  # Deviseを使っていない場合は以下も実装
  def authenticate_user!
    unless current_user
      redirect_to new_user_session_path, alert: "ログインが必要です。"
    end
  end
end
