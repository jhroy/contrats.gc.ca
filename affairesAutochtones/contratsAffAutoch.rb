#!/usr/bin/env ruby
# ©2014 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"

agence = "Affaires autochtones et Développement du Nord Canada"
n = 0 # Compteur pour compter tous les contrats

# Comme les contrats sont organisés par année et par trimestre, on crée deux boucles
# La première boucle, ci-dessous, passe une année à la fois
# La seconde, quelques lignes plus bas, est incluse dans la première et passe un trimestre à la fois

(2006..2014).each do |annee| # Les contrats de ce ministère ne reculent pas plus loin que 2006, contrairement aux autres agences qui rendent accessibles leurs contrats à partir de 2004

	fichier = "contratsAffairesAutochtones" + annee.to_s + ".csv" # Création d'un fichier pour accueillir les résultats d'une année
	tout = [] # Création d'une matrice pour accueillir les résultats d'une année

	(1..4).each do |q|

		# Deux conditions IF pour sortir des boucles lorsqu'on arrive au 3e trimestre de 2014, dont les contrats ne sont pas divulgués au moment de publier ce script

		if annee == 2014
			if q == 3
				break
			end
		end

		url = "http://www.aadnc-aandc.gc.ca/prodis/cntrcts/" + annee.to_s[-2..-1] + "-" + (annee + 1).to_s[-2..-1] + "-q" + q.to_s + "/index-fra.asp"
		puts url # Affichage de l'URL aux fins de vérification

		page1 = Nokogiri::HTML(open(url, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))
		nb = 0

		# Il y a trois difficultés, avec ce ministère: il y a plusieurs pages de contrats à chaque trimestre
		# le nombre de ces pages est différent selon le trimestre
		# et la structure du HTML est différente selon le trimestre.
		# Les trois conditions ci-dessous comptent le nombre de pages de contrats qu'il y a dans chaque trimestre en s'adaptant aux trois façons possibles d'en écrire le HTML

		if page1.at_css("div.align-right.size-small a")
			nb = page1.css("div.align-right.size-small a")

		elsif page1.at_css("div.alignRight.fontSize90 a")
			nb = page1.css("div.alignRight.fontSize90 a")
		
		elsif page1.at_css("div.alignRight a")
			nb = page1.css("div.alignRight a")
			
		end

		nbPages = nb.length / 2 # Pour une raison que je ne comprends pas, les pages sont comptées en double... J'en divise donc le nombre par deux...

		(0..nbPages-1).each do |i|
			
			numeroDePage = (i+1).to_s # Création d'un compteur nous indiquant sur quelle page, parmi toutes les pages de contrats d'un trimestre donné, on se trouve en ce moment

			# On commence par vérifier si on est sur la première page du trimestre où on est rendu (page appelée "index") où sur une des suivantes (appelées "index1", "index2", etc.) 
			# Et on crée la variable url qui contient l'adresse web de la page correspondante

			if i == 0
				url = "http://www.aadnc-aandc.gc.ca/prodis/cntrcts/" + annee.to_s[-2..-1] + "-" + (annee + 1).to_s[-2..-1] + "-q" + q.to_s + "/index-fra.asp"

			else
				url = "http://www.aadnc-aandc.gc.ca/prodis/cntrcts/" + annee.to_s[-2..-1] + "-" + (annee + 1).to_s[-2..-1] + "-q" + q.to_s + "/index" + i.to_s + "-fra.asp"

			end

			page2 = Nokogiri::HTML(open(url, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Scraping done to share public data on the web as well as to prepare for a data journalism course"))

			liste = page2.css("td a").map { |lien| lien['href'] } #obtention de la liste des URL
			liste.each do |pageContrat|

				n += 1

				contrat = {} #création d'un hash pour accueillir les données de chaque contrat

				# On commence par écrire quelques infos dans notre hash

				contrat["No"] = n
				contrat["Page"] = numeroDePage
				contrat["Agence"] = agence
				contrat["Année"] = annee
				contrat["Trimestre"] = q

				# Création de l'URL spécifique au contrat où on se trouve présentement
				
				lienContrat = "http://www.aadnc-aandc.gc.ca" + pageContrat

				page2 = Nokogiri::HTML(open(lienContrat, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca) - Extraction de données réalisée en vue de partager des données publiques sur le web, ainsi que pour préparer un cours de journalisme de données"))
				
				# Extraction des données spécifiques au contrat où on se trouve présentement

				for i in 0..7 do
					titre = page2.css("th")[i].text.strip
					contenu = page2.css("td")[i].text.strip
					contrat[titre] = contenu
				end

				# Affichage des résultats pendant l'extraction, aux fins de vérification

				puts contrat
				puts "----------"

				tout.push contrat # Ajout du hash du contrat qu'on vient d'extraire dans notre matrice de tous les contrats
			
			end

		end

	end

	CSV.open(fichier, "wb") do |csv|
	  csv << tout.first.keys
	  tout.each do |hash|
	  csv << hash.values
	end

end

end
