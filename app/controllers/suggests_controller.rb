class SuggestsController < ApplicationController
  # ===========================================
  # フィルター：ログインしていないユーザーのアクセス制限
  # ===========================================

  # Deviseなどの認証ライブラリを使用している場合、
  # このbefore_actionによりログインしていないユーザーは
  # 本コントローラ内のすべてのアクションにアクセスできないようになる
  before_action :authenticate_user!

  # ===========================================
  # 一覧表示（indexアクション）
  # ===========================================

  # ログイン中のユーザーが過去に作成した提案（Suggest）を取得し、
  # 作成日時が新しい順に並び替えて@suggestsに格納する
  def index
    @suggests = current_user.suggests.order(created_at: :desc)
  end

  # ===========================================
  # 新規作成フォームの表示（newアクション）
  # ===========================================

  # フォーム用に新しい空のSuggestインスタンスを作成して、
  # ビューに渡すことでフォーム入力を可能にする
  def new
    @suggest = Suggest.new
  end

  # ===========================================
  # 提案の作成処理（createアクション）
  # ===========================================

  # フォームから送信された内容を元に新しい提案を作成し保存する
  # 保存が成功した場合は、OpenAIを用いてAIの提案を取得し、
  # その内容をresponseカラムに保存する
  def create
    # 現在ログイン中のユーザーに紐づく新しい提案を作成
    @suggest = current_user.suggests.build(suggest_params)

    # バリデーションを含めた保存処理
    if @suggest.save
      # 保存が成功した場合、OpenAiServiceを呼び出してAIによる提案を取得
      suggest_response = OpenAiService.fetch_suggest(@suggest.input)

      # 取得したAIの提案をSuggestモデルのresponseカラムに保存
      @suggest.update(response: suggest_response)

      # 詳細ページ（show）にリダイレクトし、成功メッセージを表示
      redirect_to @suggest, notice: "AIから提案を受けました。"
    else
      # バリデーションエラーなどで保存に失敗した場合、
      # 入力値を保持したままフォームを再表示（HTTPステータスコード422）
      render :new, status: :unprocessable_entity
    end
  end

  # ===========================================
  # 詳細表示（showアクション）
  # ===========================================

  # ログイン中のユーザーが作成した特定の提案をID指定で取得し、
  # 詳細情報を表示する
  def show
    # 自分の提案のみ参照可能。他人の提案を参照しようとした場合はエラーとなる
    @suggest = current_user.suggests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # 存在しないIDや、他人の提案にアクセスしようとした場合のエラーハンドリング
    redirect_to suggests_path, alert: "指定されたアドバイスは見つかりませんでした。"
  end

  # ===========================================
  # 提案の削除（destroyアクション）
  # ===========================================

  # ログイン中のユーザーが自分で作成した提案を削除する処理
  def destroy
    # 自分の提案の中から、指定されたIDの提案を取得
    @suggest = current_user.suggests.find(params[:id])

    # 提案をデータベースから削除（失敗時は例外が発生）
    @suggest.destroy!
  end

  private

  # ===========================================
  # Strong Parameters（ストロングパラメータ）
  # ===========================================

  # フォームから送信されるパラメータのうち、
  # :suggestキーの中にある:input属性のみを許可することで
  # セキュリティを高める（マスアサインメント対策）
  def suggest_params
    params.require(:suggest).permit(:input)
  end
end
