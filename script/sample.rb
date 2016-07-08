require_relative '../lib/wiki_pr_grabber'
require_relative '../lib/evo_bracket_grabber'
require_relative '../lib/gg_pr_grabber'
require 'set'

w = WikiPrGrabber.new
e = EvoBracketGrabber.new
gg = GgPrGrabber.new
base_list = ['john lemon', 'Dr. Bread', 'Sax', 'Swedish Delight', "mattdotzeb", "BERT | 7ent", "sfat"]
#pr_map = w.get_all_players
pr_map = gg.player_region_map
e.compare_list_to_all_brackets(base_list, pr_map)