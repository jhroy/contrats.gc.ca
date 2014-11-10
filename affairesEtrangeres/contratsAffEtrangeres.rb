#!/usr/bin/env ruby
# ©2014 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"

agence = "Affaires étrangères, Commerce et Développement Canada"
fichier = "contratsAffairesEtrangeres.csv" #création d'un fichier pour accueillir nos résultats
tout = [] #création d'une matrice pour accueillir tous les contrats
n = 0 #compteur pour compter des contrats

page = Nokogiri::HTML(open("http://www.acdi-cida.gc.ca/acdi-cida/contrats-contracts.nsf/Fra/16C6928A19368D2885257497006D09A6", "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

n += 1
contrat = {} #création d'un hash pour accueillir les données de chaque contrat
contrat["No"] = n
contrat["Agence"] = agence
contrat["Année"] = 2004
contrat["Trimestre"] = 4

for i in 0..6 do
	titre = page.css("th")[i].text.strip
	contenu = page.css("td")[i].text.strip
	titre = titre[0..-3]
	contrat[titre] = contenu
end

tout.push contrat

(2010..2014).each do |annee|

	(1..4).each do |q|

		url = "http://www.acdi-cida.gc.ca/acdi-cida/Contrats-Contracts.nsf/vQuarter-Fra?OpenView&RestrictToCategory=" + (annee - 1).to_s + "-" + annee.to_s + "-Q" + q.to_s
		puts url

		page1 = Nokogiri::HTML(open(url, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

		liste = page1.css("td.alignLeft a").map { |lien| lien['href'] } #obtention de la liste des URL à partir de la page du 1er trimestre 2014
		nbContrats = liste.length
		# puts liste

		liste.each do |pageContrat| #boucle pour passer au travers de chacun des URL

			n += 1
			contrat = {} #création d'un hash pour accueillir les données de chaque contrat
			contrat["No"] = n
			contrat["Agence"] = agence
			contrat["Année"] = annee
			contrat["Trimestre"] = q

			lienContrat = "http://www.acdi-cida.gc.ca" + pageContrat 
			puts lienContrat #affichage de l'URL aux fins de vérification
			puts "No = " + n.to_s + ", " + annee.to_s + " trim " + q.to_s + " (" + nbContrats.to_s + ")"
			nbContrats -= 1
			
			page2 = Nokogiri::HTML(open(lienContrat, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Extraction de données réalisée en vue de partager des données publiques sur le web, ainsi que pour préparer un cours de journalisme de données"))
			
			for i in 0..7 do
				if page2.css("th")[i] == nil
					break
				end
				titre = page2.css("th")[i].text.strip
				contenu = page2.css("td")[i].text.strip
				titre = titre[0..-3]
				contrat[titre] = contenu
			end

			tout.push contrat
			# sleep 0.05 #pause syndicale

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
