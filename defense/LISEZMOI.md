Défense nationale et Forces canadiennes
=====

Vous trouverez ici plusieurs scripts:

- **contratsDefense.rb** est la première version que j'ai écrite... mais à l'usage, il s'est avéré peu pratique vu la quantité phénoménale de contrats à extraite (plus de 130 000 sur 10 ans). Ce script n'a jamais pu rouler sans interruption. Il plantait toujours après quelques trimestres extraits, surtout en raison de *timeouts*. J'ai donc dû briser l'opération en plusieurs scripts différents.
  - **contratsDefense-txt.rb** d'abord. Il sert à extraire la liste des URLs de tous les contrats et créé, pour chacun des trimestres, un fichier texte de la liste de ces URLs. On se servira de ce fichier dans la deuxième script.
  - **contratsDefense-trim.rb**. J'en suis rapidement venu à la conclusion qu'il était plus efficace de n'extraire qu'un seul trimestre à la fois. C'est ce que fait ce deuxième script. Parfois, il plante. Pour diagnostiquer le problème, j'ai créé un troisième script.
  - **contratsDefense-verif.rb** ne fait qu'afficher dans Terminal l'URL d'un contrat responsable d'un plantage du script *contratsDefense-trim.rb*.
