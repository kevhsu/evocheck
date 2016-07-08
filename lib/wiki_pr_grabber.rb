require 'nokogiri'
require 'httpclient'
require 'set'
require 'json'

class WikiPrGrabber
  BASE_URL = "http://www.ssbwiki.com/Category:American_Power_Rankings"

  def initialize()
    @http_client = HTTPClient.new
  end

  def grab_ranking_links()
    ret_val = Set.new
    doc = Nokogiri::HTML.parse(@http_client.get(BASE_URL).body)
    links = doc.css("div.mw-content-ltr//ul/li/a")
    links.each do |link|
      ret_val << "http://www.ssbwiki.com#{link['href']}"
    end
    ret_val
  end

  def get_all_players
    ret_val = {}
    pr_file = File.expand_path('../../tmp/wiki_pr.json', __FILE__)
    if File.exists?(pr_file)
      ret_val = JSON.parse(File.read(pr_file))
    else
      grab_ranking_links.each do |link|
        ret_val.merge!(get_players_from_link(link))
      end
      File.open(pr_file, "w") do |f|
        f.write(ret_val.to_json)
      end
    end
    ret_val
  end

  def get_players_from_link(pr_link)
    ret_val = {}
    grab_pr_tables(pr_link).each do |table|
      ret_val.merge!(parse_table(table))
    end
    ret_val
  end

  # return a map of players to ranks
  def parse_table(table)
    ret_val = {}
    rows = table.xpath('//tr')
    rows.drop(1).each do |row|
      if row.at_xpath('td[2]') && row.at_xpath('td[1]')
        name = row.at_xpath('td[2]').content.strip.downcase
        ret_val[name] = row.at_xpath('td[1]').content.strip
      end
    end
    ret_val
  end

  # doc should be a link to a pr_page
  def grab_pr_tables(pr_link)
    doc = Nokogiri::HTML.parse(@http_client.get(pr_link).body)
    ret_val = Set.new
    base = doc.xpath('//*[@id="Super_Smash_Bros._Melee_rankings"]').first
    if base.nil?
      nil
    else
      potential_heading = base.parent.next_element
      potential_table = potential_heading.next_element
      while(potential_heading.matches?("h3") && potential_table.matches?("table.wikitable")) do
        #ret_val << [potential_heading.content.strip, potential_table]
        ret_val << potential_table
        potential_heading = potential_table.next_element
        potential_table = potential_heading.next_element
      end
    end
    ret_val
  end
end
