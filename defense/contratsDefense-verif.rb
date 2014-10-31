#!/usr/bin/env ruby
#©2014 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"

#court script pour trouver, lorsque le script plante, quel URL est responsable

annee = 2013 #à changer au besoin
q = 3 #à changer au besoin
fichtxt = "listeURL-" + annee.to_s + "-" + q.to_s + ".txt"

File.open(fichtxt).readlines.each_with_index do |pageContrat, z|

	if z == 285 #valeur à changer au besoin
		puts pageContrat
	end

end
