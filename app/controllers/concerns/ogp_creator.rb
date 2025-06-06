class OgpCreator
  require "mini_magick"
  BASE_IMAGE_PATH = "./app/assets/images/ogp.png"
  GRAVITY = "north"
  TEXT_POSITION = "0,100"
  FONT ="./app/assets/fonts/NotoSansJP-Regular.ttf"
  FONT_SIZE = 60
  FONT_SIZE_USER = 30
  INDENTION_COUNT = 18
  ROW_LIMIT = 3

  def self.build(text)
    text = prepare_text(text)
    image = MiniMagick::Image.open(BASE_IMAGE_PATH)
    image.combine_options do |config|
      config.font FONT
      config.fill "red"
      config.gravity GRAVITY
      config.pointsize FONT_SIZE
      config.draw "text #{TEXT_POSITION} '#{text}'"
    end
  end

  private
  def self.prepare_text(text)
    text.to_s.scan(/.{1,#{INDENTION_COUNT}}/)[0...ROW_LIMIT].join("\n")
  end
end
