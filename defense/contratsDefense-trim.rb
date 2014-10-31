#!/usr/bin/env ruby
#©2014 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "nokogiri"
require "open-uri"

annee = 2014 #à changer selon l'année où vous êtes rendu
q = 1 #à changer selon le trimestre où vous êtes rendu
temp = ""
fichtxt = "listeURL-" + annee.to_s + "-" + q.to_s + ".txt" #nom du fichier texte où on va aller puiser les URLs

agence = "Défense nationale et les Forces canadiennes"
fichier = "contratsDefense" + annee.to_s + "-" + q.to_s + temp + ".csv" #création d'un fichier pour accueillir nos résultats
tout = [] #création d'une matrice pour accueillir tous les contrats

File.open(fichtxt).readlines.each_with_index do |pageContrat, z| #lecture du fichier txt, un URL à la fois, avec compteur (index)

	# puts pageContrat.size

	if z > 0 and z < 2000 #certains trimestres ont un nombre tellement important de contrats qu'il faut en extraire les contrats en plusieurs passes; cette boucle permet de briser l'opération pour les 2000 premiers contrats, par exemple

		contrat = Hash.new #création d'un hash pour accueillir les données de chaque contrat
		contrat["No"] = z
		contrat["Agence"] = agence
		contrat["Année"] = annee
		contrat["Trimestre"] = q
		lienContrat = "http://www.admfincs.forces.gc.ca/apps/dc/" + pageContrat.to_s
		page2 = Nokogiri::HTML(open(lienContrat, "User-Agent" => "Jean-Hugues Roy, UQAM (roy.jean-hugues@uqam.ca)"))
		puts pageContrat #affichage d'une partie de l'URL aux fins de vérification
		puts z
		for i in 0..6 do #boucle passant dans chacune des 7 lignes du tableau affichant les données relatives à un contrat
			if page2.css("th")[i] == nil #certains tableaux contiennent des lignes qui sont en fait inexistantes; on teste cette éventualité ici
				titre = ""
				contenu = ""
			else
				titre = page2.css("th")[i].text.strip
				contenu = page2.css("td")[i].text.strip
				# puts titre
				# puts contenu
			end
			contrat[titre] = contenu
		end
		tout.push contrat
		sleep 0.1 #le serveur du ministère mérite un petit break; très petit
	end

end
	
# écriture des résultats dans un fichier CSV

CSV.open(fichier, "wb") do |csv|
  csv << tout.first.keys
  tout.each do |hash|
    csv << hash.values
  end
end
