class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick


  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end


  def default_url(*args)
    "/images/fallback/" + [ version_name, "default_study_logs_image.png" ].compact.join("_")
  end


  def extension_allowlist
    %w[jpg jpeg gif png]
  end


  process resize_to_limit: [ 800, 800 ]


  version :thumb do
    process resize_to_fill: [ 40, 40 ]
  end
end
