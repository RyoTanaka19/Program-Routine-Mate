# app/services/wikipedia_fetcher.rb
require "net/http"
require "uri"
require "json"

class WikipediaFetcher
  def self.fetch_summary(keyword)
    encoded_keyword = URI.encode_www_form_component(keyword)
    url = URI("https://ja.wikipedia.org/api/rest_v1/page/summary/#{encoded_keyword}")

    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      json = JSON.parse(response.body)
      json["extract"] || "情報が見つかりませんでした。"
    else
      "Wikipediaから情報を取得できませんでした。"
    end
  end
end
