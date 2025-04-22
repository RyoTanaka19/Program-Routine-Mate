# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [ :edit, :update ]
   protected

   def after_sign_up_path_for(resource)
     # 登録後は学習ログ一覧ページへ遷移（例：ダッシュボードのような役割）
     study_logs_path
   end

   def update_resource(resource, params)
     # 通常 Devise は、メールやパスワード変更時に現在のパスワード確認を求めるが、
     # この設定によりパスワード入力なしでプロフィールなどを更新できるようになる
     resource.update_without_password(params)
   end

   def after_update_path_for(resource)
     # 更新後はそのユーザーのプロフィールページへ遷移
     users_profile_path(current_user.id)
   end
end
