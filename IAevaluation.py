i = 0
indiceWTrouve = 0
nbGagnantX = 0
nbGagnantY = 0
gagnantCourant = 'nul'

NOMBRE_ITERATIONS = 10

for j in range(0,NOMBRE_ITERATIONS) :
	print("Iteration N°", j)
	#Lancement du processus
	import subprocess
	result = subprocess.run(['swipl', '-s', './ReversoMerged.pl', '-t' ,'init'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

	for line in result.stdout.decode('utf-8') :
		#On compte juste le nombre de lignes
		i = i+1
	
		#Typical line : "Game is Over. Winner: x"
		#On détecte l'affichage du W de "Winner"
		value = line.find("W")

		#Si on a trouvé le W, on se prépare à capture la valeur du gagnant
		if value != -1 :
			indiceWTrouve = i
			#DEBUG # print("Valeur W trouvée en position :", indiceWTrouve)
		
		#A l'emplacement où on devrait trouver le gagnant, on le capture
		#if indiceWTrouve !=0 :
		#	print(">", line)
		if indiceWTrouve !=0 and i == indiceWTrouve+9 :
			gagnantCourant = line
			#DEBUG # print("Valeur du gagnant trouvée :", gagnantCourant)
		
			#On range le résultat du tirage actuel
			if gagnantCourant == 'x' :
				nbGagnantX = nbGagnantX +1
			elif gagnantCourant == 'o' : 
				nbGagnantY = nbGagnantY +1
		
		#Remise à zéro pour le prochain tour
		gagnantCourant = 'nul'


	
print ("Total de victoire pour X :", nbGagnantX)
print ("Total de victoire pour O :", nbGagnantY)
print ("Total de", i, "caractères parsées")
print ("Estimation d'environ", i/84, "tours joués")