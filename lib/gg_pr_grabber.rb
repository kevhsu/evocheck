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

  def method_name
    
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
    puts "rankings page #{page_num}"
    body = @http.get(RANKING_INDEX_URL + page_num.to_s).body
    doc = Nokogiri::HTML.parse(body)

    ranking_pages ||= doc.css("div.gg-card/a").map{|card| BASE_URL + card['href']}
  end

  def player_region_map
    ret_val = {}
    pr_file = File.expand_path('../../tmp/gg_pr.json', __FILE__)
    if File.exists?(pr_file)
      ret_val = JSON.parse(File.read(pr_file))
    else
      get_all_ranking_urls.each do |url|
        puts "parsing #{url}"
        ret_val.merge!(parse_ranking_page(url))
      end
      File.open(pr_file, "w") do |f|
        f.write(ret_val.to_json)
      end
    end
    ret_val
  end

  def parse_ranking_page(ranking_url)
    body = @http.get(ranking_url).body
    doc = Nokogiri::HTML.parse(body)
    ret_val = {}

    ranking_name = doc.at_css('h3.heading-no-margin-bottom').content
    players = doc.css('div.gamertag-title').map{|player| player.content}
    players.each do |player|
      ret_val[player] = ranking_name
    end
    ret_val
  end
end

g = GgPrGrabber.new
#puts g.get_all_ranking_urls
g.player_region_map
