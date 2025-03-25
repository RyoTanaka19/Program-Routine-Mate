class ProposalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @proposals = current_user.proposals.order(created_at: :desc)
  end

  def new
    @proposal =Proposal.new
  end

  def create
    @proposal = current_user.proposals.build(proposal_params)
    if @proposal.save
      # サービスクラスを利用してAIのアドバイスを取得
      proposal_response = OpenAiService.fetch_proposal(@proposal.input)
      @proposal.update(response: proposal_response)
      redirect_to @proposal, notice: "AIから提案を受けました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # 現在のユーザーに関連する提案のみを表示
    @proposal = current_user.proposals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to proposals_path, alert: "指定されたアドバイスは見つかりませんでした。"
  end

  private

  def proposal_params
    params.require(:proposal).permit(:input)
  end
end
