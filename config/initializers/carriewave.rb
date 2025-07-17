require "carrierwave/storage/abstract"
require "carrierwave/storage/file"
require "carrierwave/storage/fog"

CarrierWave.configure do |config|
  if Rails.env.production?  # 本番環境の場合
    config.storage :fog                     # fog（AWS S3）を使う
    config.fog_provider = "fog/aws"         # fogのプロバイダーをAWSに指定
    config.fog_directory = ENV["AWS_BUCKET_NAME"]  # S3のバケット名を環境変数から取得
    config.fog_public = false                # アップロードファイルは非公開に設定
    config.fog_credentials = {               # AWS認証情報を環境変数から設定
      provider: "AWS",
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region: ENV["AWS_REGION"],
      path_style: true
    }
  else                      # 開発・テスト環境の場合
    config.storage :file    # ローカルファイルに保存
    config.enable_processing = false if Rails.env.test?  # テスト環境は処理を無効化
  end
end
