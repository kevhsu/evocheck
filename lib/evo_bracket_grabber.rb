require 'nokogiri'
require 'httpclient'
require 'set'

class EvoBracketGrabber
  BASE_URL = "http://evo2016.s3.amazonaws.com/brackets/ssbm_replace_me.html"
  def bracket_links
    num_range = (1..25).to_a
    letter_range = ('a'..'e').to_a
    links = Set.new
    num_range.each do |num|
      letter_range.each do |let|
        links << BASE_URL.gsub("replace_me", "#{let}6#{num.to_s.rjust(2,'0')}") unless (let == 'e' and num == 25)
      end
    end
    links.each do |link|
      puts link
    end
  end
end