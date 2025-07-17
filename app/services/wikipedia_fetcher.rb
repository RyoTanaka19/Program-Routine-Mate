# app/services/wikipedia_fetcher.rb
require "net/http"
require "uri"
require "json"

class WikipediaFetcher
  # 指定されたキーワードのWikipedia要約を取得するクラスメソッド
  def self.fetch_summary(keyword)
    # キーワードをURLエンコード
    encoded_keyword = URI.encode_www_form_component(keyword)
    # WikipediaのREST APIのURLを生成
    url = URI("https://ja.wikipedia.org/api/rest_v1/page/summary/#{encoded_keyword}")

    # APIへHTTP GETリクエストを送る
    response = Net::HTTP.get_response(url)

    # レスポンスが成功ならJSONをパースして要約文を返す
    if response.is_a?(Net::HTTPSuccess)
      json = JSON.parse(response.body)
      json["extract"] || "情報が見つかりませんでした。"
    else
      # エラー時のメッセージを返す
      "Wikipediaから情報を取得できませんでした。"
    end
  end
end
