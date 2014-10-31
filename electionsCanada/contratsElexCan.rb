#!/usr/bin/env ruby
#©2014 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"

agence = "Élections Canada"
fichier = "contratsElectionsCanada.csv" #création d'un fichier pour accueillir nos résultats
tout = [] #création d'une matrice pour accueillir tous les contrats
n = 0 #compteur pour compter des contrats

(2004..2014).each do |annee|

	(1..4).each do |q|

		if annee == 2014

			if q >= 2 #deux conditions pour tenir compte du fait que seulement le 1er trimestre de 2014 était publié au moment de l'extraction

				break

			end

		end

		url = "http://www.elections.ca/contracts/default.asp?textonly=false&lang=f&action=list&year=" + annee.to_s + "&quarter=" + q.to_s
		puts url

		page1 = Nokogiri::HTML(open(url, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

		liste = page1.css("td a").map { |lien| lien['href'] } #obtention de la liste des URL à partir de la page du 1er trimestre 2014

		liste.each do |pageContrat| #boucle pour passer au travers de chacun des URL

			n += 1
			contrat = {} #création d'un hash pour accueillir les données de chaque contrat
			contrat["No"] = n
			contrat["Agence"] = agence
			contrat["Année"] = annee
			contrat["Trimestre"] = q

			lienContrat = "http://www.elections.ca" + pageContrat.to_s
			puts lienContrat #affichage de l'URL aux fins de vérification
			
			page2 = Nokogiri::HTML(open(lienContrat, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))
			
			for i in 0..8 do

				titre = page2.css("th.colord.alignLeft")[i].text.strip
				contenu = page2.css("td.colorf")[i].text.strip
				# puts "Le (ou la) " + titre + " est " + contenu #affichage du titre et du contenu pour vérification

				contrat[titre] = contenu

			end

			tout.push contrat

		end

	end

end

puts tout

CSV.open(fichier, "wb") do |csv|
  csv << tout.first.keys
  tout.each do |hash|
    csv << hash.values
  end
end
