class SuggestsController < ApplicationController
  # ===========================================
  # フィルター（ログインしていないとアクセス不可）
  # ===========================================

  # Deviseなどの認証ライブラリを使用している場合、
  # このbefore_actionにより、ログインしていないユーザーは
  # すべてのアクションにアクセスできなくなる
  before_action :authenticate_user!

  # ===========================================
  # 一覧表示（indexアクション）
  # ===========================================

  # ログイン中のユーザーが作成した提案（Suggest）を
  # 作成日時が新しい順に取得し、@suggestsに格納
  def index
    @suggests = current_user.suggests.order(created_at: :desc)
  end

  # ===========================================
  # 新規作成フォームの表示（newアクション）
  # ===========================================

  # 新しい提案を作成するための空のSuggestオブジェクトを生成し、
  # フォームで利用できるよう@suggestに格納
  def new
    @suggest = Suggest.new
  end

  # ===========================================
  # 提案の作成処理（createアクション）
  # ===========================================

  # フォームから送信された内容をもとに新しい提案を作成・保存し、
  # 保存に成功したらOpenAiServiceを用いてAIの提案を取得・保存
  def create
    # ログイン中のユーザーに紐づく新しい提案オブジェクトを作成
    @suggest = current_user.suggests.build(suggest_params)

    # 入力内容だけでまず保存（バリデーションチェックを含む）
    if @suggest.save
      # 保存に成功した場合、OpenAiServiceからAIによる提案を取得
      suggest_response = OpenAiService.fetch_suggest(@suggest.input)

      # AIから得た提案をresponseカラムに保存（追記保存）
      @suggest.update(response: suggest_response)

      # showページ（詳細表示）にリダイレクトし、通知メッセージを表示
      redirect_to @suggest, notice: "AIから提案を受けました。"
    else
      # 保存に失敗した場合は、入力内容を保持したままフォームを再表示
      # HTTPステータスコード422（Unprocessable Entity）を明示的に指定
      render :new, status: :unprocessable_entity
    end
  end

  # ===========================================
  # 詳細表示（showアクション）
  # ===========================================

  # 特定の提案をIDで取得し、詳細ページに表示する
  def show
    # 他のユーザーの提案を見られないよう、
    # ログイン中のユーザーの提案の中からIDで検索
    @suggest = current_user.suggests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # 存在しないID、または他人の提案だった場合、
    # 一覧ページにリダイレクトし、エラーメッセージを表示
    redirect_to suggests_path, alert: "指定されたアドバイスは見つかりませんでした。"
  end

  # ===========================================
  # 提案の削除（destroyアクション）
  # ===========================================

  # ユーザー自身が作成した提案を削除する処理
  def destroy
    # 現在のユーザーの提案の中から該当するIDのものを取得
    @suggest = current_user.suggests.find(params[:id])

    # 提案を削除（失敗した場合は例外が発生し、500エラー等に）
    @suggest.destroy!
  end

  private

  # ===========================================
  # Strong Parameters（ストロングパラメータ）
  # ===========================================

  # フォームから送られてきたパラメータのうち、
  # :suggestキーの中の:input属性のみを許可
  def suggest_params
    params.require(:suggest).permit(:input)
  end
end
