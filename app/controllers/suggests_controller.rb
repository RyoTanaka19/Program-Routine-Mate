class SuggestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @suggests = current_user.suggests.order(created_at: :desc)
  end

  def new
    @suggest = Suggest.new
  end

  def create
    @suggest = current_user.suggests.build(suggest_params)

    if @suggest.save
      suggest_response = OpenAiService.fetch_suggest(@suggest.input)

      @suggest.update(response: suggest_response)

      redirect_to @suggest, notice: "AIコーチから提案を受けました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @suggest = current_user.suggests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to suggests_path, alert: "指定されたアドバイスは見つかりませんでした。"
  end

  def destroy
    @suggest = current_user.suggests.find(params[:id])
    @suggest.destroy!
    redirect_to suggests_path, notice: "AIコーチからの提案を削除しました。"
  end

  private

  def suggest_params
    params.require(:suggest).permit(:input)
  end
end
