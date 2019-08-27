#La liste initiale des IAs
L = ['random', 'greedy', 'greedyDepth2', 'greedyValued', 'heuristicOneLevel', 'heuristicNlevels', 'mc', 'mcts']
#DEBUG # print(L)

i = 0
for val1 in L:
	for val2 in L:
		i +=1
		val = 'init' + str(i)
		print(val, ' :- init(\'x\', ', val1, ', ', val2, ',_, _).')
		#DEBUG # print(val1,val2)


