class StudyGenresController < ApplicationController
def index
  raw_stats = StudyGenre.includes(:study_logs).flat_map do |genre|
    genre.study_logs.map do |log|
      { name: genre.name, user_id: log.user_id }
    end
  end

  grouped = raw_stats.group_by { |entry| entry[:name] }

  @genre_stats = grouped.map do |name, entries|
    display_name = case name
    when "PHP_(プログラミング言語)" then "PHP"
    else name
    end

    {
      name: display_name,
      post_count: entries.count,
      user_count: entries.map { |e| e[:user_id] }.uniq.count
    }
  end.sort_by { |stat| -stat[:user_count] }
end





  def new
    if current_user.nil?
      redirect_to new_user_session_path, alert: "ログインが必要です。"
      return
    end

    @study_genre = current_user.study_genres.new

    @study_genres = current_user.study_genres.order(created_at: :desc)

    @last_genre = @study_genres.first

    @has_21_days_of_logs = current_user.study_logs
  .pluck(:created_at)
  .map(&:to_date)
  .uniq
  .count >= 21
  end


def create
  last_genre = current_user.study_genres.order(created_at: :desc).first

  if current_user.study_genres.empty?
    @study_genre = current_user.study_genres.new(study_genre_params)

    if current_user.study_genres.exists?(name: @study_genre.name)
      flash.now[:alert] = "すでに設定しているジャンルは設定できません。"
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages", partial: "shared/flash_messages") }
      end
      return
    end

  elsif last_genre.present? && has_21_days_of_logs?(last_genre)
    @study_genre = current_user.study_genres.new(study_genre_params)

    if current_user.study_genres.exists?(name: @study_genre.name)
      flash.now[:alert] = "すでに設定しているジャンルは設定できません。"
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages", partial: "shared/flash_messages") }
      end
      return
    end

  else
    flash.now[:alert] = "新しいジャンルを設定する条件が満たされていません。"
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages", partial: "shared/flash_messages") }
    end
    return
  end

  if @study_genre.save
    redirect_to new_study_log_path(study_genre_id: @study_genre.id), notice: "ジャンルが設定されました。"
  else
    render :new
  end
end



  def edit
    @study_genre = StudyGenre.find(params[:id])

    if @study_genre.user != current_user
      flash[:alert] = "アクセス権限がありません。"
      redirect_to study_genres_path
    end
  end


def update
  @study_genre = StudyGenre.find(params[:id])

  if @study_genre.user != current_user
    flash[:alert] = "アクセス権限がありません。"
    redirect_to study_genres_path and return
  end

  new_name = params[:study_genre][:name]

  if current_user.study_genres.exists?(name: new_name) && @study_genre.name != new_name
    flash.now[:alert] = "他で設定しているジャンルと同じ名前は設定できません。"
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("study_genre_form", partial: "study_genres/form", locals: { study_genre: @study_genre }),
          turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
        ]
      end
    end
    return
  end

  if @study_genre.name == new_name
    flash.now[:alert] = "現在のジャンルでの更新はできません。"
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("study_genre_form", partial: "study_genres/form", locals: { study_genre: @study_genre }),
          turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
        ]
      end
    end
    return
  end

  if @study_genre.name != new_name
    @study_genre.study_logs.update_all(study_genre_id: nil)
  end

  if @study_genre.update(study_genre_params)
    flash[:notice] = "ジャンルが更新されました。"
    redirect_to new_study_log_path(study_genre_id: @study_genre.id)
  else
    flash.now[:alert] = "ジャンルの更新に失敗しました。"
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("study_genre_form", partial: "study_genres/form", locals: { study_genre: @study_genre }),
          turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
        ]
      end
    end
  end
end

  def show
    @study_genre = StudyGenre.find_by(id: params[:id])

    if @study_genre.nil?
      flash[:alert] = "指定されたジャンルは見つかりません。"
      redirect_to study_genres_path
      return
    end

    if @study_genre.user != current_user
      flash[:alert] = "アクセス権限がありません。"
      render :index
      return
    end

    @wikipedia_summary = WikipediaFetcher.fetch_summary(@study_genre.name)



    respond_to do |format|
      format.html
      format.json do
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

  def has_21_days_of_logs?(genre)
  return false if genre.study_logs.empty?

  # 記録された学習日（created_atの日付部分）をユニークに取得
  study_days = genre.study_logs.pluck(:created_at).map(&:to_date).uniq

  # 21日分の異なる日があればOK
  study_days.count >= 21
end

  def study_genre_params
    params.require(:study_genre).permit(:name)
  end
end
