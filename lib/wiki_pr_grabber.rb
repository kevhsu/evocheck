require 'nokogiri'
require 'httpclient'
require 'set'

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

  # return a map of players to ranks
  def parse_table(table)
    ret_val = {}
    rows = table.xpath('//tr')
    rows.drop(1).each do |row|
      name = row.at_xpath('td[2]').content.strip
      ret_val[name] = row.at_xpath('td[1]').content.strip
    end
    ret_val
  end

  # doc should be a nokogiri parsed pr page
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
        ret_val << [potential_heading.content.strip, potential_table]
        potential_heading = potential_table.next_element
        potential_table = potential_heading.next_element
      end
    end
    ret_val
  end
end
