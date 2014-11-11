#!/usr/bin/env ruby
# ©2014 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"

agence = "Conseil de la radiodiffusion et des télécommunications canadiennes (CRTC)"
fichier = "contratsCRTC.csv" #création d'un fichier pour accueillir nos résultats
tout = [] #création d'une matrice pour accueillir tous les contrats
n = 0 #compteur pour compter des contrats

(2004..2014).each do |annee|

	(1..4).each do |q|

		url = "https://services.crtc.gc.ca/pub/Expenses/rapport-report/trimestre-quarter/?lang=fr&q=" + q.to_s + "&year=" + annee.to_s

		page1 = Nokogiri::HTML(open(url, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

		liste = page1.css("td a").map { |lien| lien['href'] } #obtention de la liste des URL à partir de la page du 1er trimestre 2014
		
		liste.each do |pageContrat| #boucle pour passer au travers de chacun des URL

			n += 1
			contrat = {} #création d'un hash pour accueillir les données de chaque contrat
			contrat["No"] = n
			contrat["Agence"] = agence
			contrat["Année"] = annee
			contrat["Trimestre"] = q

			lienContrat = "https://services.crtc.gc.ca/pub/Expenses/" + pageContrat[6..-1].to_s
			puts lienContrat #affichage de l'URL aux fins de vérification
			
			page2 = Nokogiri::HTML(open(lienContrat, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))
			
			for i in 0..6 do

				titre = page2.css("th")[i].text.strip
				contenu = page2.css("td")[i].text.strip
				contrat[titre] = contenu

			end

			puts contrat
			puts "----------"

			tout.push contrat

		end

	end

end

CSV.open(fichier, "wb") do |csv|
  csv << tout.first.keys
  tout.each do |hash|
    csv << hash.values
  end
end
