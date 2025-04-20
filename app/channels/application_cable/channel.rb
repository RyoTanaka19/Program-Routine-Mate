# app/channels/application_cable/channel.rb

# このモジュールは、Action Cable の全チャンネルで共通の機能や設定を定義するための基盤となる名前空間です。
# すべてのカスタムチャンネルクラスは、この Channel クラスを継承することで共通の振る舞いを引き継ぎます。

module ApplicationCable
  # アプリケーション内のすべての Action Cable チャンネルのベースクラスです。
  # 必要に応じて、全チャンネルで共通に使用するメソッドやフィルターなどをここに定義できます。
  class Channel < ActionCable::Channel::Base
  end
end
