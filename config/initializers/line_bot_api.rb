LINE_BOT_API = Line::Bot::Client.new { |config|
  config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
  config.channel_token = ENV["LINE_CHANNEL_ACCESS_TOKEN"]
}
