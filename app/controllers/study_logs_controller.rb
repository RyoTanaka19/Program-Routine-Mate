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
    # ransackを使って検索オブジェクトを作成する（検索フォームなどから送られたパラメータをもとに条件を構築）
    @q = StudyLog.ransack(params[:q])

   # パラメータに学習ジャンルID（study_genre_id）が存在する場合、そのジャンルに該当する記録だけをさら に絞り込む
   @q.study_genre_id_eq = params[:study_genre_id] if params[:study_genre_id].present?

   # 検索・絞り込み結果から学習記録を取得し、以下の処理を適用：
   # - 重複を排除（distinct: true）
   # - 関連するユーザー情報も同時に読み込むことでN+1問題を回避（includes(:user)）
   # - 作成日時の昇順で並び替え（order(created_at: :asc)）
   # - ページネーションを適用（page(params[:page])）
   @study_logs = @q.result(distinct: true).includes(:user).order(created_at: :asc).page(params[:page])

    # ユーザーの学習記録によるランキング（学習日数順）
    @ranking = User.studied_logs_days_ranking.limit(3)

    # ユーザーの学習記録をJavaScriptで表示するためにデータを加工
    @study_logs_for_js = current_user ? current_user.study_logs.where.not(date: nil).map { |log| { date: log.date.to_date, total: log.try(:total) || 0 } } : []

    @study_genres = StudyGenre.all  # 学習ジャンルのリストを取得
  end

  def autocomplete
    # Ransackを使用して検索オブジェクトを作成
    # params[:q]に検索条件が含まれており、それを基にRansackで検索を設定します
    @q = StudyLog.ransack(params[:q])

    # ジャンル指定がある場合、明示的に検索条件を設定
    # セーフに取り出すためにparams.digを使用し、study_genre_name_eqが存在する場合のみ処理を行う
    if params.dig(:q, :study_genre_name_eq).present?
      # ジャンル条件を検索オブジェクトに設定
      @q.study_genre_name_eq = params[:q][:study_genre_name_eq]
    end

    # 検索結果を取得
    # resultメソッドで検索を実行し、distinct: trueを指定して重複するレコードを排除します
    # limit(10)でオートコンプリート用に結果を最大10件に制限
    @study_logs = @q.result(distinct: true).limit(10)

    # 結果をJSON形式で返す
    # .as_jsonメソッドで、必要なカラム（content）だけを抽出してレスポンスに含める
    # これにより、オートコンプリート機能に必要なデータのみを最小限で返すことができます
    render json: @study_logs.as_json(only: [ :content ])
  end

  # 🏆 学習記録のランキングを表示するアクション
  def ranking
    # Userモデルのクラスメソッド `studied_logs_days_ranking` を呼び出して、
    # 各ユーザーの学習ログに基づく学習日数を集計し、
    # 学習日数の多い順に並べたユーザーのランキング情報を取得する。
    @ranking = User.studied_logs_days_ranking
  end


  # 📄 学習記録の詳細ページを表示するアクション
  def show
    # 指定されたIDの学習記録を1件取得
    # params[:id]から学習記録のIDを取得し、それに対応するStudyLogオブジェクトをデータベースから検索
    @study_log = StudyLog.find(params[:id])

    # コメント投稿用の新規オブジェクト（form_withなどで使用）
    # 新しいLearningCommentオブジェクトを作成し、コメントフォームで使用するために準備
    @learning_comment = LearningComment.new

    # 現在の学習記録に紐づくコメント一覧を取得
    # 学習記録に関連するコメントを、ユーザー情報を一緒に読み込み、作成日時（created_at）を降順で取得
    # includes(:user)でコメントに関連するユーザー情報を一度に読み込み、N+1クエリを防止
    @learning_comments = @study_log.learning_comments.includes(:user).order(created_at: :desc)

    # OGP（Open Graph Protocol）やTwitterカードなど、SNS向けのメタタグ設定を行う
    # 現在の学習記録に基づいて、SNSでシェアされたときに表示されるメタタグを準備
    prepare_meta_tags(@study_log)
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
