# CarrierWaveのストレージに関する基本クラスを読み込む
# CarrierWaveは、ファイルアップロードの際にストレージの種類を選べるライブラリ
# 以下は、使用するストレージのバックエンドクラスを読み込む
require "carrierwave/storage/abstract"  # CarrierWaveの抽象的なストレージクラス
require "carrierwave/storage/file"      # ローカルファイルシステム用のストレージクラス
require "carrierwave/storage/fog"       # fog（AWS S3など）を使うためのストレージクラス

# CarrierWaveの設定ブロック
CarrierWave.configure do |config|
  # 本番環境ではAmazon S3（fog経由）をストレージとして使用する
  if Rails.env.production?
    # ストレージとしてfog（Amazon S3などのクラウドサービス）を指定
    config.storage :fog

    # 使用するストレージプロバイダを指定（AWSを使用する）
    config.fog_provider = "fog/aws"  # AWSを使用するためにfogライブラリを指定

    # 使用するS3バケット名を指定（環境変数から取得）
    # 本番環境で使用するS3バケット名を指定。環境変数から取得することでセキュリティ確保
    config.fog_directory = ENV["AWS_BUCKET_NAME"]

    # アップロードされたファイルは非公開に設定
    # S3のファイルを公開しない設定。必要に応じて公開設定も可能。
    config.fog_public = false

    # AWSの認証情報を環境変数から取得し、設定
    # セキュリティ上、アクセスキーやシークレットキーは環境変数から取得することが推奨される
    config.fog_credentials = {
      provider: "AWS",  # プロバイダー名（必須）
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],  # AWSのアクセスキーID（環境変数から）
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],  # AWSのシークレットアクセスキー（環境変数から）
      region: ENV["AWS_REGION"],  # 使用するAWSリージョン（例：'ap-northeast-1' 東京リージョン）
      path_style: true  # バケットのパススタイルアクセスを有効化（必要な場合、互換性のために設定）
    }
  else
    # 本番環境以外（開発・テスト）ではローカルファイルに保存
    # 開発環境やテスト環境では、S3などのクラウドストレージではなく、ローカルのファイルシステムに保存する
    config.storage :file

    # テスト環境では画像処理を無効にして高速化
    # テスト環境では画像処理を行う必要がない場合、処理を無効化することでテスト速度を向上させる
    config.enable_processing = false if Rails.env.test?
  end
end
