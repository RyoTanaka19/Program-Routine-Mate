# app/services/wikipedia_fetcher.rb
require "net/http"
require "uri"
require "json"

class WikipediaFetcher
  # 指定されたキーワードのWikipedia要約を取得するクラスメソッド
  def self.fetch_summary(keyword)
    encoded_keyword = URI.encode_www_form_component(keyword)
    url = URI("https://ja.wikipedia.org/api/rest_v1/page/summary/#{encoded_keyword}")

    begin
      response = Net::HTTP.get_response(url)

      case response
      when Net::HTTPSuccess
        json = JSON.parse(response.body)
        json["extract"].presence || "Wikipediaに該当する情報が見つかりませんでした。"
      when Net::HTTPNotFound
        "Wikipediaに該当するページが存在しません。"
      else
        "Wikipediaから情報を取得できませんでした。ステータス: #{response.code}"
      end

    rescue SocketError => e
      "ネットワーク接続に失敗しました（#{e.message}）"
    rescue Timeout::Error => e
      "Wikipediaの応答がタイムアウトしました（#{e.message}）"
    rescue JSON::ParserError => e
      "Wikipediaから取得したデータの解析に失敗しました（#{e.message}）"
    rescue StandardError => e
      "予期しないエラーが発生しました（#{e.class}: #{e.message}）"
    end
  end
end
