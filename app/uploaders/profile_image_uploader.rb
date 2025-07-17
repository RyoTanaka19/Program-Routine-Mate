class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick  # 画像処理にMiniMagickを使用

  # 環境によって保存方法を切り替え
  if Rails.env.production?
    storage :fog   # 本番はクラウドストレージ（例: AWS S3）
  else
    storage :file  # 開発・テストはローカル保存
  end

  # アップロードファイルの保存ディレクトリを指定
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # アップロードがない場合のデフォルト画像のURLを返す
  def default_url(*args)
    "/images/fallback/" + [ version_name, "default_study_logs_image.png" ].compact.join("_")
  end

  # 許可するファイル拡張子のリスト
  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  # アップロード画像を最大800x800にリサイズ
  process resize_to_limit: [ 800, 800 ]

  # サムネイル画像（40x40）を作成
  version :thumb do
    process resize_to_fill: [ 40, 40 ]
  end
end
