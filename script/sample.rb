require_relative '../lib/wiki_pr_grabber'
require_relative '../lib/evo_bracket_grabber'
require 'set'

w = WikiPrGrabber.new
e = EvoBracketGrabber.new
base_list = ['john lemon', 'Dr. Bread', 'Sax']
pr_map = w.get_all_players
e.compare_list_to_all_brackets(base_list, pr_map)