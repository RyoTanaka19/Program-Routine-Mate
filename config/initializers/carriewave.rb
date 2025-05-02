# CarrierWaveのストレージに関する基本クラスを読み込む
require "carrierwave/storage/abstract"
require "carrierwave/storage/file"
require "carrierwave/storage/fog"

# CarrierWaveの設定
CarrierWave.configure do |config|
  # 本番環境ではAmazon S3（fog経由）をストレージとして使用する
  if Rails.env.production?
    config.storage :fog  # ストレージにfogを指定
    config.fog_provider = "fog/aws"  # fogでAWSを利用する設定
    config.fog_directory = ENV["AWS_BUCKET_NAME"]  # 使用するS3バケット名（環境変数で設定）
    config.fog_public = false  # アップロードされたファイルを非公開に設定

    # AWSの認証情報を指定（環境変数を利用）
    config.fog_credentials = {
      provider: "AWS",  # プロバイダー名（必須）
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],  # アクセスキー（環境変数から）
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],  # シークレットキー（環境変数から）
      region: ENV["AWS_REGION"],  # 利用するリージョン（例：'ap-northeast-1'）
      path_style: true  # バケットのパススタイルアクセスを有効化（必要な場合）
    }
  else
    # 本番環境以外（開発・テスト）はローカルファイルに保存
    config.storage :file

    # テスト環境では画像処理を無効にして高速化
    config.enable_processing = false if Rails.env.test?
  end
end
