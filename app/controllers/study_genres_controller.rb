class StudyGenresController < ApplicationController
  # 新規ジャンル作成ページを表示するアクション
  def new
    # ログインしていない場合は、ログインページにリダイレクト
    if current_user.nil?
      redirect_to new_user_session_path, alert: "ログインが必要です。"
      return
    end

    # 新しいジャンルオブジェクトを作成（フォーム表示用）
    @study_genre = current_user.study_genres.new

    # 現在のユーザーが持っているジャンルを新しい順に取得
    @study_genres = current_user.study_genres.order(created_at: :desc)

    # 一番最後に作成したジャンルを取得
    @last_genre = @study_genres.first
  end

  # ジャンルを新規作成するアクション
  def create
    # 最後に作成されたジャンルを取得
    last_genre = current_user.study_genres.order(created_at: :desc).first

    # 1つもジャンルがない場合の処理
    if current_user.study_genres.empty?
      # 入力されたパラメータで新しいジャンルを作成
      @study_genre = current_user.study_genres.new(study_genre_params)

      # 同じ名前のジャンルがすでに存在するかチェック
      if current_user.study_genres.exists?(name: @study_genre.name)
        flash[:alert] = "すでに設定しているジャンルは設定できません。"
        redirect_to study_genres_path
        return
      end

    # 最後に作成されたジャンルの学習ログが1件だけある場合
    elsif last_genre.present? && last_genre.study_logs.count == 1
      @study_genre = current_user.study_genres.new(study_genre_params)

      # 他のジャンルと重複していないか確認
      if current_user.study_genres.exists?(name: @study_genre.name)
        flash[:alert] = "すでに設定しているジャンルは設定できません。"
        redirect_to study_genres_path
        return
      end

    # 上記2つの条件以外の場合は登録不可
    else
      flash[:alert] = "新しいジャンルを設定する条件が満たされていません。"
      redirect_to study_genres_path
      return
    end

    # バリデーションを通れば保存して学習ログ作成ページへ遷移
    if @study_genre.save
      redirect_to new_study_log_path(study_genre_id: @study_genre.id), notice: "ジャンルが設定されました。"
    else
      # バリデーションエラーなどがあれば再度フォームを表示
      render :new
    end
  end

  # ジャンルの編集ページを表示するアクション
  def edit
    @study_genre = StudyGenre.find(params[:id])

    # 現在のユーザーのジャンルでなければアクセスを拒否
    if @study_genre.user != current_user
      flash[:alert] = "アクセス権限がありません。"
      redirect_to study_genres_path
    end
  end

  def update
    @study_genre = StudyGenre.find(params[:id])

    if @study_genre.user != current_user
      flash[:alert] = "アクセス権限がありません。"
      redirect_to study_genres_path
      return
    end

    new_name = params[:study_genre][:name]

    if current_user.study_genres.exists?(name: new_name) && @study_genre.name != new_name
      flash[:alert] = "他で設定しているジャンルと同じ名前は設定できません。"
      redirect_to study_genres_path
      return
    end

    if @study_genre.name == new_name
      flash[:alert] = "現在のジャンルでの更新はできません。"
      redirect_to study_genres_path
      return
    end

    if @study_genre.name != new_name
      @study_genre.study_logs.update_all(study_genre_id: nil)
    end

    if @study_genre.update(study_genre_params)
      flash.now[:notice] = "ジャンルが更新されました。"
      redirect_to new_study_log_path(study_genre_id: @study_genre.id), notice: "ジャンルが設定されました。"
    else
      flash.now[:alert] = "ジャンルの更新に失敗しました。"
      render :edit
    end
  end

  # ジャンルの詳細ページを表示するアクション
  def show
    @study_genre = StudyGenre.find_by(id: params[:id])

    if @study_genre.nil?
      flash[:alert] = "指定されたジャンルは見つかりません。"
      render :index
      return
    end

    if @study_genre.user != current_user
      flash[:alert] = "アクセス権限がありません。"
      render :index
      return
    end

    @wikipedia_summary = WikipediaFetcher.fetch_summary(@study_genre.name)
  end
  private

  # Strong Parameters：許可されたパラメータのみを受け取る
  def study_genre_params
    params.require(:study_genre).permit(:name, :start_time, :end_time)
  end
end
