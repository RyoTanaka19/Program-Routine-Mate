class StudyLogsImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick  # 画像処理にMiniMagickを使用

  # 環境によって保存方法を切り替え
  if Rails.env.production?
    storage :fog   # 本番環境はクラウドストレージに保存
  else
    storage :file  # 開発・テスト環境はローカル保存
  end

  # ファイルの保存ディレクトリを指定
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # 画像がアップロードされていない場合のデフォルト画像のURLを返す
  def default_url(*args)
    "/images/fallback/" + [ version_name, "default_study_logs_image.png" ].compact.join("_")
  end

  # アップロード可能な拡張子の制限
  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  # アップロード画像の最大サイズを300x200に制限（縦横比維持）
  process resize_to_limit: [ 300, 200 ]
end
