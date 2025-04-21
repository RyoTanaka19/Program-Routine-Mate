class StudyGenresController < ApplicationController
  # 新規ジャンル作成ページを表示するアクション

  def index
    raw_stats = StudyGenre.includes(:study_logs).flat_map do |genre|
      genre.study_logs.map do |log|
        { name: genre.name, user_id: log.user_id }
      end
    end

    grouped = raw_stats.group_by { |entry| entry[:name] }

    @genre_stats = grouped.map do |name, entries|
      {
        name: name,
        post_count: entries.count,
        user_count: entries.map { |e| e[:user_id] }.uniq.count
      }
    end.sort_by { |stat| -stat[:user_count] }
  end

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
        flash.now[:alert] = "すでに設定しているジャンルは設定できません。"
        render :new, status: :unprocessable_entity and return
      end

    # 最後に作成されたジャンルの学習ログが1件だけある場合
    elsif last_genre.present? && last_genre.study_logs.count >= 1
      @study_genre = current_user.study_genres.new(study_genre_params)

      # 他のジャンルと重複していないか確認
      if current_user.study_genres.exists?(name: @study_genre.name)
        flash.now[:alert] = "すでに設定しているジャンルは設定できません。"
      render :new, status: :unprocessable_entity and return
        return
      end

    # 上記2つの条件以外の場合は登録不可
    else
      flash[:alert] = "新しいジャンルを設定する条件が満たされていません。"
      render :new, status: :unprocessable_entity and return
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
    # 指定されたIDのジャンルを取得
    @study_genre = StudyGenre.find(params[:id])

    # 現在のユーザーのジャンルでなければアクセスを拒否
    if @study_genre.user != current_user
      flash[:alert] = "アクセス権限がありません。"
      redirect_to study_genres_path
    end
  end

  # ジャンル情報を更新するアクション
  def update
    # 指定されたIDのジャンルを取得
    @study_genre = StudyGenre.find(params[:id])

    # 現在のユーザーのジャンルでなければアクセスを拒否
    if @study_genre.user != current_user
      flash[:alert] = "アクセス権限がありません。"
      redirect_to study_genres_path
      return
    end

    new_name = params[:study_genre][:name]

    # 他で同じ名前のジャンルがあるか確認（現在のジャンルを除く）
    if current_user.study_genres.exists?(name: new_name) && @study_genre.name != new_name
      flash[:alert] = "他で設定しているジャンルと同じ名前は設定できません。"
      render :new, status: :unprocessable_entity and return
    end

    # 現在のジャンル名を変更しない場合は、更新処理を行わない
    if @study_genre.name == new_name
      flash.now[:alert] = "現在のジャンルでの更新はできません。"
      render :edit, status: :unprocessable_entity and return
    end

    # 名前が変更される場合、関連する学習ログを更新
    if @study_genre.name != new_name
      @study_genre.study_logs.update_all(study_genre_id: nil)
    end

    # 新しい名前に変更して更新
    if @study_genre.update(study_genre_params)
      flash[:notice] = "ジャンルが更新されました。"
      redirect_to new_study_log_path(study_genre_id: @study_genre.id)
    else
      flash.now[:alert] = "ジャンルの更新に失敗しました。"
      render :edit
    end
  end

  # ジャンルの詳細ページを表示するアクション
  def show
    # 1. 指定されたIDのジャンルをデータベースから取得
    # params[:id]で渡されたIDを使って、StudyGenreテーブルから該当するジャンルを探します。
    # find_byは、IDに一致するレコードがあればそれを返し、なければnilを返します。
    @study_genre = StudyGenre.find_by(id: params[:id])

    # 2. ジャンルが見つからない場合
    if @study_genre.nil?
      # ジャンルが見つからない場合はフラッシュメッセージを設定して、indexビューを表示する
      flash[:alert] = "指定されたジャンルは見つかりません。"
      render :index
      return  # 処理を終了
    end

    # 3. 現在のユーザーのジャンルでなければアクセスを拒否
    # @study_genre.userはそのジャンルを作成したユーザーを指します。
    # current_userは現在ログインしているユーザーで、この2つが一致しない場合、アクセスを拒否する
    if @study_genre.user != current_user
      # アクセス権限がない場合は、フラッシュメッセージを表示して、indexビューにリダイレクト
      flash[:alert] = "アクセス権限がありません。"
      render :index
      return  # 処理を終了
    end

    # 4. Wikipediaからジャンル名に関連するサマリーを取得
    # WikipediaFetcherというカスタムクラスを使って、ジャンル名に基づくWikipediaのサマリーを取得
    # 取得したサマリーは@wikipedia_summaryに格納
    @wikipedia_summary = WikipediaFetcher.fetch_summary(@study_genre.name)

    # 5. レスポンス形式に応じて処理を分岐
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

  # Strong Parameters：許可されたパラメータのみを受け取る
  def study_genre_params
    params.require(:study_genre).permit(:name)
  end
end
