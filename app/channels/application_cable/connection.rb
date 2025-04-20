# app/channels/application_cable/connection.rb

# ApplicationCable モジュールは、Action Cable の接続やチャンネルの共通の名前空間です。
module ApplicationCable
  # Connection クラスは、Action Cable における WebSocket 接続を管理するクラスです。
  # 各クライアントとの接続時に呼び出され、認証や接続ごとの情報の設定を行います。
  class Connection < ActionCable::Connection::Base
    # この識別子は、接続ごとに一意の「current_user」を識別できるように設定します。
    # 各チャンネル内でも `current_user` を使ってユーザー情報にアクセス可能になります。
    identified_by :current_user

    # クライアントが接続してきたときに呼び出されるメソッド
    def connect
      # 認証済みのユーザーを設定。失敗した場合は接続を拒否。
      self.current_user = find_verified_user
    end

    private

    # 認証されたユーザーを取得するメソッド
    def find_verified_user
      # `env["warden"]` は Devise を使っている場合にセッションからユーザー情報を取得するための仕組みです。
      if current_user = env["warden"].user
        current_user  # 認証に成功した場合、そのユーザーを返す
      else
        # 認証に失敗した場合は接続を拒否。WebSocket接続は確立されません。
        reject_unauthorized_connection
      end
    end
  end
end
