# frozen_string_literal: true

# アプリケーション全体の共通処理を定義するコントローラ
# すべてのコントローラはこのクラスを継承します
class ApplicationController < ActionController::Base
  # Deviseのコントローラが動作しているときに、許可するパラメータを追加する処理を呼び出す
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # ==========================================
  # ログイン後のリダイレクト先を指定するメソッド
  # Devise の after_sign_in_path_for メソッドをオーバーライド
  # ==========================================
  def after_sign_in_path_for(study_logs)
    # ログイン後は学習ログ一覧ページへ遷移
    study_logs_path
  end

  # ==========================================
  # ログアウト後のリダイレクト先を指定するメソッド
  # Devise の after_sign_out_path_for メソッドをオーバーライド
  # ==========================================
  def after_sign_out_path_for(new_user_session)
    # ログアウト後はトップページ（ルートパス）へ遷移
    root_path
  end

  # ==========================================
  # Deviseでユーザー登録・編集時に許可するパラメータを追加するメソッド
  # ==========================================
  def configure_permitted_parameters
    # ユーザー新規登録時に name パラメータを許可（例: ユーザー名）
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])

    # アカウント情報更新時に追加で許可するパラメータ
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [
        :name,                                 # ユーザー名
        :self_introduction,                    # 自己紹介
        :studying_continuation_systematization, # 学習継続・体系化の工夫
        :profile_image,                        # プロフィール画像
        :profile_image_cache                   # 画像キャッシュ（CarrierWaveなどで使用）
      ]
    )
  end
end
