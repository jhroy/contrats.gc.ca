#!/usr/bin/env ruby
#GPL 2014 Jean-Hugues Roy

require "csv"
require "nokogiri"
require "open-uri"

agence = "Défense nationale et les Forces canadiennes"
n = 0 #compteur

(2004..2014).each do |annee|

	(1..4).each do |q|

		if annee == 2014

			if q >= 2 #deux conditions pour tenir compte du fait que seulement le 1er trimestre de 2014 était publié au moment de l'extraction

				break

			end

		end

		tout = []  #création d'une matrice pour accueillir tous les contrats d'un trimestre donné

		url = "http://www.admfincs.forces.gc.ca/apps/dc/qua-tri-fra.asp?q=" + q.to_s + "&y=" + annee.to_s
		puts url #affichage, aux fins de vérification, de l'URL de la liste primaire des contrats pour un trimestre
		fichier = "contratsDefense" + annee.to_s + "-" + q.to_s + ".csv" #création d'un fichier pour accueillir les résultats, un trimestre à la fois

		page1 = Nokogiri::HTML(open(url, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))

		liste = page1.css("td a").map { |lien| lien['href'] }
		puts liste.length #affichage du nombre de contrats qu'on doit aller chercher pour ce trimestre

		liste.each_with_index do |pageContrat, x|
			n = n + 1
			contrat = Hash.new #création d'un hash pour accueillir les données de chaque contrat
			contrat["No"] = n
			contrat["Agence"] = agence
			contrat["Année"] = annee
			contrat["Trimestre"] = q
			lienContrat = "http://www.admfincs.forces.gc.ca/apps/dc/" + pageContrat.to_s
			page2 = Nokogiri::HTML(open(lienContrat, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))
			puts pageContrat #affichage d'une partie de l'URL aux fins de vérification
			puts liste.length - (x + 1) #affichage d'un compte à rebours pour suivre l'évolution de l'extraction
			for i in 0..6 do
				if page2.css("th")[i] == nil #exclusion de champs vides qui, autrement, font planter le script
					titre = ""
					contenu = ""
				else
					titre = page2.css("th")[i].text.strip
					contenu = page2.css("td")[i].text.strip
				end
				contrat[titre] = contenu
			end
			tout.push contrat
			sleep 0.25 #petite pause café
		end

		# écriture des résultats dans un fichier CSV pour chacun des trimestres

		CSV.open(fichier, "wb") do |csv|
		  csv << tout.first.keys
		  tout.each do |hash|
		    csv << hash.values
		  end
		end

	end

end
