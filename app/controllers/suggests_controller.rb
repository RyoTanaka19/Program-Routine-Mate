class SuggestsController < ApplicationController
  # ユーザーが認証されていない場合は、すべてのアクション実行前にログインを要求する
  before_action :authenticate_user!

  # indexアクション
  # 現在のユーザーが作成した提案を作成日順に並べて表示
  def index
    @suggests = current_user.suggests.order(created_at: :desc)
  end

  # newアクション
  # 新しい提案を作成するフォームを表示
  def new
    @suggest = Suggest.new
  end

  # createアクション
  # ユーザーがフォームから送信したデータを基に新しい提案を作成
  def create
    # 現在のユーザーが所有する提案を作成
    @suggest = current_user.suggests.build(suggest_params)

    # 提案の保存に成功した場合
    if @suggest.save
      # OpenAiServiceを使ってAIから提案を取得
      suggest_response = OpenAiService.fetch_suggest(@suggest.input)

      # AIからの提案を提案レコードに保存
      @suggest.update(response: suggest_response)

      # 提案が作成された後、その提案ページにリダイレクト
      redirect_to @suggest, notice: "AIから提案を受けました。"
    else
      # 保存に失敗した場合、フォームを再表示
      render :new, status: :unprocessable_entity
    end
  end

  # showアクション
  # ユーザーが作成した特定の提案を表示
  def show
    # 現在のユーザーが所有する提案をIDで検索
    @suggest = current_user.suggests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # 提案が見つからない場合、提案一覧ページにリダイレクトし、エラーメッセージを表示
    redirect_to suggests_path, alert: "指定されたアドバイスは見つかりませんでした。"
  end

  def destroy
    @suggest= current_user.suggests.find(params[:id])
    @suggest.destroy!
  end

  private

  # 提案に関するパラメータの許可リスト
  def suggest_params
    # ユーザーが送信したparamsからinput属性のみ許可する
    params.require(:suggest).permit(:input)
  end
end
