class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # Include RMagick, MiniMagick, or Vips support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  # include CarrierWave::Vips

  # Choose what kind of storage to use for this uploader:

# Railsの環境に応じてファイルの保存方法を切り替える設定です。

# 本番環境（production）では、外部ストレージ（例えばAmazon S3やGoogle Cloud Storageなど）を使用してファイルを保存します。
# これは、クラウドストレージを使ってスケーラブルで高可用性のあるファイルストレージを確保するためです。
if Rails.env.production?
  storage :fog
# 本番環境以外（開発環境やテスト環境）では、ローカルファイルシステムを使用してファイルを保存します。
# 開発中やテスト時は、ファイルの保存先としてローカルディスクを利用することが一般的です。
else
  storage :file
end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    "/images/fallback/" + [ version_name, "default_study_logs_image.png" ].compact.join("_")
  end


  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fill: [ 40, 40 ]
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg"
  # end
end
