#!/usr/bin/env ruby
# ©2014 Jean-Hugues Roy

require "csv"
require "nokogiri"
require "open-uri"

(2004..2014).each do |annee|

	(1..4).each do |q| #il faudrait une boucle pour arrêter après le 1er trimestre 2014, mais je fais un ctrl-c à la place; inélégant, je sais, j'assume

		fichtxt = "listeURL-" + annee.to_s + "-" + q.to_s + ".txt" #création d'un nom de fichier txt pour écrire la liste des URLs des contrats du MDN par trimestre

		url = "http://www.admfincs.forces.gc.ca/apps/dc/qua-tri-fra.asp?q=" + q.to_s + "&y=" + annee.to_s
		puts url

		page1 = Nokogiri::HTML(open(url, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))

		liste = page1.css("td a").map { |lien| lien['href'] }
		puts liste
		puts liste.length #affichages pour vérification

		File.open(fichtxt, "w+") do |f| #écriture du fichier txt
		  liste.each { |element| f.puts(element) }
		end

	end

end
