require 'nokogiri'
require 'httpclient'
require 'set'
require 'json'

class GgPrGrabber
  RANKING_INDEX_URL = "https://smash.gg/rankings/melee?per_page=50&filter=%7B%22published%22%3Atrue%2C%22videogameId%22%3A1%2C%22locationType%22%3A%5B3%2C4%2C5%2C6%2C7%2C8%5D%2C%22regionGroup%22%3A%22ALL%22%7D&page="
  BASE_URL = "https://smash.gg"

  def initialize
    @http = HTTPClient.new
  end

  def get_all_ranking_urls
    index = 1
    ret_val = []
    begin
      page_urls = get_ranking_urls(index)
      ret_val += page_urls
      index += 1
    end until page_urls.empty?
    ret_val
  end

  def get_ranking_urls(page_num)
    body = @http.get(RANKING_INDEX_URL + page_num.to_s).body
    doc = Nokogiri::HTML.parse(body)

    ranking_pages = doc.css("div.gg-card/a").map{|card| BASE_URL + card['href']}
  end
end

g = GgPrGrabber.new
puts g.get_all_ranking_urls