require 'nokogiri'
require 'httpclient'
require 'set'

class EvoBracketGrabber
  BASE_URL = "http://evo2016.s3.amazonaws.com/brackets/ssbm_replace_me.html"

  def initialize
    @http_client = HTTPClient.new
  end

  def bracket_links
    num_range = (1..25).to_a
    letter_range = ('a'..'e').to_a
    links = Set.new
    num_range.each do |num|
      letter_range.each do |let|
        links << BASE_URL.gsub("replace_me", "#{let}6#{num.to_s.rjust(2,'0')}") unless (let == 'e' and num == 25)
      end
    end
    links
  end

  def grab_player_names(bracket_link)
    doc = Nokogiri::HTML.parse(@http_client.get(bracket_link).body)
    # the gsub takes care of non breaking spaces...
    players = doc.css("div.match-1x//div.player-handle").map{ |player| player.content.strip.downcase.gsub(/\p{Space}/, '')}.to_set
    players
  end

  def compare_list_to_all_brackets(base_list, pr_list)
    bracket_links.each do |link|
      compare_list_to_bracket(link, base_list, pr_list)
    end
  end

  def compare_list_to_bracket(bracket_link, base_list, pr_list)
    bracket_players = grab_player_names(bracket_link)
    base_intersection = bracket_players & base_list
    unless base_intersection.empty?
      puts "#{base_intersection.to_a.join(', ')} is in #{bracket_link}" 
      pr_intersection = pr_list.keys.to_set & bracket_players
      unless pr_intersection.empty?
        puts "#{pr_intersection.to_a.join(', ')} is also in the above bracket"
      end
    end
  end

  def get_all_player_names
    names = Set.new
    bracket_links.each do |link|
      names += grab_player_names(link)
    end
    names
  end
end
