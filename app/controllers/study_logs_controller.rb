class StudyLogsController < ApplicationController
  # 認証が必要なアクションを定義。showとindexは認証なしでアクセス可能。
  before_action :authenticate_user!, except: [ :show, :index, :autocomplete ]

  # 新しい学習記録のフォームを表示するアクション
  def new
    @study_log = StudyLog.new  # 新しいStudyLogオブジェクトを作成
    @study_genre = current_user.study_genres.last  # ユーザーが選択した最新の学習ジャンルを取得
    @study_reminder = current_user.study_reminders.last  # ユーザーの最新の学習リマインダーを取得

    # ユーザーがジャンルを選択していない場合
    if @study_genre.nil?
      flash[:alert] = "ジャンルを先に設定してください"
      redirect_to new_study_genre_path  # ジャンル設定ページにリダイレクト
    else
      @study_log.study_genre_id = @study_genre.id  # 新しい学習記録にジャンルIDを設定
    end
  end

  # 学習記録を作成するアクション
  def create
    @study_log = current_user.study_logs.new(study_log_params)
    @study_genre = StudyGenre.find_by(id: params[:study_log][:study_genre_id]) || current_user.study_genres.last

    if @study_genre.nil?
      flash.now[:alert] = "指定された学習ジャンルが見つかりませんでした。"
      render :new, status: :unprocessable_entity and return
    end

    # UserStudyGenreの登録（既存の場合はスキップ）
    user_study_genre = UserStudyGenre.find_or_create_by(user: current_user, study_genre: @study_genre)

    if @study_log.save
      notice = "学習記録が作成されました！"
      notice += "（投稿時刻が学習時間外のため、学習時間は記録されませんでした）" if @study_log.total.nil?
      redirect_to study_logs_path, notice: notice
    else
      flash.now[:alert] = "学習記録の作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  # 学習記録を編集するアクション
  def edit
    @study_log = current_user.study_logs.find(params[:id])  # 編集対象の学習記録を取得
    # 学習記録に紐づくジャンルが設定されていなければ、ユーザーの最新ジャンルを設定
    @study_genre = @study_log.study_genre || current_user.study_genres.last
  end

  # 学習記録を更新するアクション
  def update
    @study_log = current_user.study_logs.find(params[:id])  # 更新対象の学習記録を取得
    # 更新処理が成功すれば一覧ページへリダイレクト
    if @study_log.update(study_log_params)
      redirect_to study_logs_path, notice: "学習記録の変更をしました。"
    else
      # 更新に失敗した場合、エラーメッセージを表示して再度フォームを表示
      flash.now[:alert] = "学習記録の変更に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  # 学習記録を削除するアクション
  def destroy
    study_log = current_user.study_logs.find(params[:id])  # 削除対象の学習記録を取得
    study_log.destroy  # 学習記録を削除
    redirect_to study_logs_path, notice: "学習記録の削除をしました。"  # 削除後に一覧ページにリダイレクト
  end

  # 学習記録の一覧を表示するアクション
  def index
    @q = StudyLog.ransack(params[:q])  # ransackで検索条件を作成
    @q.study_genre_id_eq = params[:study_genre_id] if params[:study_genre_id].present?  # ジャンルIDで絞り込み

    # 絞り込んだ学習記録をページネーション付きで取得
    @study_logs = @q.result(distinct: true).includes(:user).order(created_at: :asc).page(params[:page])

    # ユーザーの学習記録によるランキング（学習日数順）
    @ranking = User.studied_logs_days_ranking.limit(3)

    # ユーザーの学習記録をJavaScriptで表示するためにデータを加工
    @study_logs_for_js = current_user ? current_user.study_logs.where.not(date: nil).map { |log| { date: log.date.to_date, total: log.try(:total) || 0 } } : []

    @study_genres = StudyGenre.all  # 学習ジャンルのリストを取得
  end

  def autocomplete
    @q = StudyLog.ransack(params[:q])
  
    if params.dig(:q, :study_genre_name_eq).present?
      @q.study_genre_name_eq = params[:q][:study_genre_name_eq]
    end
  
    @study_logs = @q.result(distinct: true).limit(10)
    render json: @study_logs.as_json(only: [:content])
  end

  # 学習記録のランキングを表示するアクション
  def ranking
    @ranking = User.studied_logs_days_ranking  # 学習記録によるランキングを取得
  end

  # 学習記録の詳細ページを表示するアクション
  def show
    @study_log = StudyLog.find(params[:id])  # 対象の学習記録を取得
    @learning_comment = LearningComment.new  # 新しいコメントオブジェクトを作成
    @learning_comments = @study_log.learning_comments.includes(:user).order(created_at: :desc)  # コメントを降順で取得
    prepare_meta_tags(@study_log)  # メタタグの設定（OGPなど）
  end

  private

  # ストロングパラメーター：学習記録に許可されたパラメーターを定義
  def study_log_params
    params.require(:study_log).permit(:content, :text, :image, :image_cache, :date, :study_genre_id, :study_reminder_id, :count)
  end

  # メタタグを設定するためのプライベートメソッド
  def prepare_meta_tags(study_log)
    image_url = "#{request.base_url}/images/ogp.png?text=#{CGI.escape(study_log.content)}"  # OGP画像のURLを作成
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
