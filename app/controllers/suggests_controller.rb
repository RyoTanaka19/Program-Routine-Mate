class SuggestsController < ApplicationController
  # ===========================================
  # フィルター：ログインしていないユーザーのアクセス制限
  # ===========================================

  # Deviseなどの認証ライブラリを使用している場合、
  # このbefore_actionによりログインしていないユーザーは
  # 本コントローラ内のすべてのアクションにアクセスできないようにする
  before_action :authenticate_user!

  # ===========================================
  # 一覧表示（indexアクション）
  # ===========================================

  # ログイン中のユーザーが過去に作成した提案（Suggest）を取得
  # 作成日時が新しい順に並び替えて、@suggestsインスタンス変数に格納
  # これにより、ユーザーの提案一覧が表示される
  def index
    @suggests = current_user.suggests.order(created_at: :desc)
  end

  # ===========================================
  # 新規作成フォームの表示（newアクション）
  # ===========================================

  # 新しい空のSuggestインスタンスを作成し、それをビューに渡してフォームに表示
  # これにより、ユーザーが新しい提案を作成できるフォームを表示できる
  def new
    @suggest = Suggest.new
  end

  # ===========================================
  # 提案の作成処理（createアクション）
  # ===========================================

  # フォームから送信された内容を元に、新しい提案（Suggest）を作成して保存する
  # 提案が無事に保存された場合、AI（OpenAiService）を呼び出して提案内容を生成し、responseカラムに保存
  def create
    # 現在ログイン中のユーザーに紐づく新しい提案を作成（current_user.suggests.build）
    # これにより、提案は必ずログイン中のユーザーに関連付けられる
    @suggest = current_user.suggests.build(suggest_params)

    # 提案を保存し、保存が成功した場合
    if @suggest.save
      # OpenAiServiceを呼び出して、AIによる提案を取得
      suggest_response = OpenAiService.fetch_suggest(@suggest.input)

      # AIからの提案内容をresponseカラムに保存
      @suggest.update(response: suggest_response)

      # 提案の詳細ページにリダイレクトし、成功メッセージを表示
      redirect_to @suggest, notice: "AI(プログラミング)コーチから提案を受けました。"
    else
      # バリデーションエラーなどで保存に失敗した場合
      # 入力値を保持したままフォームを再表示（HTTPステータスコード422）
      render :new, status: :unprocessable_entity
    end
  end

  # ===========================================
  # 詳細表示（showアクション）
  # ===========================================

  # ログイン中のユーザーが作成した特定の提案をID指定で取得し、詳細情報を表示する
  # 他のユーザーの提案にアクセスしようとするとエラーを返し、指定された提案が見つからなければエラーを表示
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
  # 提案が削除できるのは、現在のユーザーが作成した提案だけ
  def destroy
    # 自分の提案の中から、指定されたIDの提案を取得
    @suggest = current_user.suggests.find(params[:id])

    # 提案をデータベースから削除（失敗時は例外が発生）
    @suggest.destroy!

    # 一覧ページにリダイレクトし、削除完了のメッセージを表示
    redirect_to suggests_path, notice: "AI(プログラミング)コーチからの提案を削除しました。"
  end

  private

  # ===========================================
  # Strong Parameters（ストロングパラメータ）
  # ===========================================

  # フォームから送信されるパラメータのうち、:suggestキーの中にある:input属性のみを許可する
  # これにより、悪意のあるパラメータが送信されるのを防ぎ、セキュリティを高める
  # マスアサインメント（Mass Assignment）を防ぐための対策
  def suggest_params
    params.require(:suggest).permit(:input)
  end
end
