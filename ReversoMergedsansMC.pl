%%%%%%%%%%% Elements utiles %%%%%%%%%%%
% The game state will be represented by a list of 9 elements
% board(_,_,_,_,_,.....,_,_,_,_) at the beginning (64 cases)

:- dynamic board/1.

%Pour le MC
:- dynamic boardMC/1.
:- dynamic lJoues/1.
:- dynamic lGagnes/1.
% TaillePlateau(8). % Possible de paramétrer la tailler du plateau ?


%%%%%%%%%%%%%%%%%%%% End of game %%%%%%%%%%%%%%%%%%%%
%%% Calculate the number of points of a player across the board
% [Liste] : plateau ou liste de cases, P : joueur ('x' ou 'o'), Nb : nombre de pions du joueur P
	nbOfPoints([], _, 0).
	% la tête de la liste est un pion du joueur P	
	nbOfPoints([TBoard|QBoard], P, Nb) :- nonvar(TBoard),  TBoard == P, nbOfPoints(QBoard, P, Nb2), Nb is Nb2+1, !.
	% la tête de la liste n'est pas un pion du joueur P (case vide ou pion adverse)
	nbOfPoints([_|QBoard], P, Nb) :- nbOfPoints(QBoard, P,Nb), !.

%%% Defines if board is full : no move left for any player (get result for one player and then the other)
% Board : plateau de jeu
	isBoardFull(Board) :- casesJouables(Board, 0, 'x', CasesJouablesX), % plus aucun coup n'est jouable par 'x'
		length(CasesJouablesX, NbCasesJouablesX),
		NbCasesJouablesX is 0, casesJouables(Board, 0, 'o', CasesJouablesO), % plus aucun coup n'est jouable par 'o'
		length(CasesJouablesO, NbCasesJouablesO), NbCasesJouablesO is 0.

%%% Test if a Board is a draw or which player wins
% Board : plateau de jeu, P1 : 'x' ou 'o' ou 'Egalite' (renvoyé à gameover)
	% les deux joueurs ont le même nombre de points
	winner(Board, 'Egalite') :- nbOfPoints(Board, 'x', NbPointsX), nbOfPoints(Board, 'o', NbPointsO), NbPointsX == NbPointsO, !.
	% 'x' ou 'o' (via changePlayer) a plus de points que son adversaire
	winner(Board, P1) :- changePlayer(P1, P2),  nbOfPoints(Board, P1, NbPointsP1), nbOfPoints(Board, P2, NbPointsP2), NbPointsP1 > NbPointsP2, !.

%%% GameOver if board is full and we have a winner ('x', 'o' ou 'Egalite')
% Winner : 'x', 'o' ou 'Egalite'
	gameover(Winner) :- board(Board), isBoardFull(Board), winner(Board, Winner), !.

%%% Besoin : Fonction qui converti deux valeur I (0-7),J(0-7) en l'indice de la case du tableau 0-64
% X : colonnes
% Y : lignes
	coordXYtoVal(X,Y,Val) :- Val is X + Y * 8.
	coordValtoXY(X,Y,Val) :- X is Val mod 8, Y is Val div 8.


%%%%%%%%%%%%%%%%%%%% Heuristiques %%%%%%%%%%%%%%%%%%%%	
%%% Heuristique totale
	totalHeuristic(Board, Player, TotalValue) :- 
    	pointsHeuristic(Board, Player, ValuePH),
    	cornersHeuristic(Board, Player, ValueCH),
    	cornersNeighboursHeuristic(Board, Player, ValueCNH),
    	mobilityHeuristic(Board, Player, ValueMH),
    	emptyNeighboursHeuristic(Board, Player, ValueNH),
    	stabilityHeuristic(Board, Player, ValueSH),
    	calculateTotalHeuristic(ValuePH, ValueCH, ValueCNH, ValueMH, ValueNH, ValueSH, TotalValue).
    
	% Formule provenant de l'article : poids relatifs fournissant les meilleurs résultats
	% Article :
	% "An Analysis of Heuristics in Othello"
	% Vaishnavi Sannidhanam and Muthukaruppan Annamalai
	% Department of Computer Science and Engineering,
	% University of Washington,
	% Seattle
    calculateTotalHeuristic(ValuePH, ValueCH, ValueCNH, ValueMH, ValueNH, _, TotalValue) :-
    	TotalValue is (25 * ValuePH) + (30 * ValueCH) + (20 * ValueCNH) +
    	(10 * ValueNH) + (5 * ValueMH).


%%% Heuristique points
	% heuristique sur la répartition des pions du plateau entre les joueurs, [-100,100]
	% plus on a de pions (par rapport à l'adversaire) plus la configuration est intéressante
	pointsHeuristic(Board, Player, Value) :-	
		nbOfPoints(Board, Player, NbPPlayer), % on récupère le nombre de pions du joueur
		changePlayer(Player, Opponent),
		nbOfPoints(Board, Opponent, NbPOpponent), % on récupère le nombre de pions de l'adversaire
		calculatePointsHeuristicValue(NbPPlayer, NbPOpponent, Value), !. % on calcule la valeur de l'heuristique
		
	% le joueur a plus de pions que son adversaire : valeur positive
	calculatePointsHeuristicValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0, NbP > NbO, Value is (100 * NbP) / Somme.
	% le joueur a moins de pions que son adversaire : valeur négative
	calculatePointsHeuristicValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0, NbP < NbO, Value is -(100 * NbO) / Somme.
	% les joueurs ont le même nombre de pions : valeur nulle
	calculatePointsHeuristicValue(_, _, Value) :- Value is 0.


%%% Heuristique coins
	% heuristique sur sur la répartition des quatre coins du plateau entre les joueurs, [-100,100]
	% plus on possède de coins (par rapport à l'adversaire), plus la configuration est intéressante
	cornersHeuristic(Board, Player, Value) :-
		nbOfCorners(Board, Player, NbPPlayer), % on récupère le nombre de coins du joueur
    	changePlayer(Player, Opponent),
    	nbOfCorners(Board, Opponent, NbPOpponent), % on récupère le nombre de coins de l'adversaire
    	calculateCornersHeuristicValue(NbPPlayer, NbPOpponent, Value), !. % on calcule la valeur de l'heuristique

	calculateCornersHeuristicValue(NbP, NbO, Value) :- Value is 25 * (NbP - NbO).
	
	% calcule le nombre de coins possédés par le joueur Player
	nbOfCorners(Board, Player, Value) :-
    	isPlayerPoint(Board, Player, 0, V0), % coin haut-gauche
    	isPlayerPoint(Board, Player, 7, V7), % coin haut-droite
    	isPlayerPoint(Board, Player, 56, V56), % coin bas-gauche
    	isPlayerPoint(Board, Player, 63, V63), % coin bas-droit
    	Value is V0 + V7 + V56 + V63. % on calcule le nombre de coins total

	% vérifie si la case à l'index Index est un pion du joueur Player
	% renvoie Valeur qui vaut 1 si c'est le cas, 0 sinon
	isPlayerPoint(Board, Player, Index, Value) :-
    	nth0(Index, Board, Elem),
    	nonvar(Elem),
    	Elem==Player,
    	Value is 1, !.
	isPlayerPoint(_, _, _, Value) :-
    	Value is 0.


%%% Heuristique voisins de coins
	% heuristique sur la répartition des cases voisines des quatre coins du plateau, [-100, 100]
	% On ne compte que les cases voisines au coin si le coin est vide.
	% Plus il y a sur les cases voisines de pions adverses, mieux c'est, car on a alors d'autant plus
	% de possibilités de prendre les coins.
	cornersNeighboursHeuristic(Board, Player, Value) :-
		nbOfCornersNeighbours(Board, Player, NbPPlayer), % on récupère le nombre de cases voisines des coins du joueur
    	changePlayer(Player, Opponent),
    	nbOfCornersNeighbours(Board, Opponent, NbPOpponent), % on récupère le nombre de cases voisines des coins de l'adversaire
    	calculateCornersNeighboursHeuristicValue(NbPPlayer, NbPOpponent, Value), !. % on calcule la valeur de l'heuristique

	calculateCornersNeighboursHeuristicValue(NbP, NbO, Value) :- Value is -8.3 * (NbP - NbO).
    
	% calcule le nombre de cases voisines de coins possédées par le joueur Player
	nbOfCornersNeighbours(Board, Player, Value) :-
		computeOneCornersNeighbours(Board, Player, 0, 1, 8, 9, VTL), % coin haut-gauche
		computeOneCornersNeighbours(Board, Player, 7, -1, 7, 8, VTR), % coin haut-droite
		computeOneCornersNeighbours(Board, Player, 56, -8, -7, 1, VBL), % coin bas-gauche
		computeOneCornersNeighbours(Board, Player, 63, -1, -8, -9, VBR), % coin bas-droit
		% on calcule le nombre de voisins des coins total
    	Value is VTL + VTR + VBL + VBR, !.
	
	% calcule le nombre de cases voisines d'un coin (si ce coin est vide) possédées pas le joueur
	computeOneCornersNeighbours(Board, Player, Index, Inc1, Inc2, Inc3, Value) :-
		nth0(Index, Board, Elem), 
		var(Elem), % vérifie si le coin est bien vide
    	Ind1 is Index+Inc1,
		isPlayerPoint(Board, Player, Ind1, V1),
    	Ind2 is Index+Inc2,
		isPlayerPoint(Board, Player, Ind2, V2),
    	Ind3 is Index+Inc3,
    	isPlayerPoint(Board, Player, Ind3, V3),
		Value is V1 + V2 + V3.
	computeOneCornersNeighbours(_, _, _, _, _, _, Value) :-
		Value is 0.


%%% Heuristique nombre de déplacement
	% heuristique sur le rapport entre le nombre de déplacements possibles des deux joueurs, [-100,100]
	% Plus on a de déplacements possibles (par rapport à l'adversaire), plus on a de possibilités et
	% donc de chances d'obtenir une configuration intéressante
	mobilityHeuristic(Board, Player, Value) :-
    	casesJouables(Board, 0, Player, CJP), length(CJP, LP), % on récupère le nombre de cases jouables par le joueur
    	changePlayer(Player, Opponent),
    	casesJouables(Board, 0, Opponent, CJO), length(CJO, LO), % on récupère le nombre de cases jouables par l'adversaire
    	calculateMobilityValue(LP, LO, Value), !. % on calcule la valeur de l'heuristique
	
	% le joueur a plus de déplacements possible que son adversaire : valeur positive
	calculateMobilityValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0,  NbP > NbO, Value is (100 * NbP) / Somme.
	% le joueur a moins de déplacements possible que son adversaire : valeur négative
	calculateMobilityValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0,  NbP < NbO, Value is -(100 * NbO) / Somme.
	% les joueurs ont le même nombre de déplacements : valeur nulle
	calculateMobilityValue(_, _, Value) :- Value is 0.


%%% Heuristique pions potentiellement prenables
	% heuristique sur le nombre de pions du joueur voisins d'une case vide, [-100,100]
	% plus le nombre de pions prenables du joueur (par rapport à l'adversaire) est faible,
	% plus la configuration est intéressante
	emptyNeighboursHeuristic(Board, Player, Value) :-
    	emptyNeighboursForPlayer(Board, Player, 0, NbP),
    	changePlayer(Player, Opponent),
		emptyNeighboursForPlayer(Board, Opponent, 0, NbO),
    	calculateEmptyNeighboursValue(NbP, NbO, Value), !.
    
	% calcule le nombre de pions prenables (ayant un voisin vide) pour le joueur Player
	emptyNeighboursForPlayer(_, _, 64, FinalValue) :- FinalValue is 0, !.
	emptyNeighboursForPlayer(Board, Player, Index, FinalValue) :-
    	Index2 is Index+1,
    	emptyNeighboursForPlayer(Board, Player, Index2, Value2),
    	hasEmptyNeighbour(Board, Player, Index, Value), % on vérifie si la case a un voisin vide
    	FinalValue is Value+Value2, !.

	% le joueur a plus de pions prenables que son adversaire : valeur négative
	calculateEmptyNeighboursValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0, NbP > NbO, Value is -(100 * NbP) / Somme.
	% le joueur a moins de pions prenables que son adversaire : valeur positive
	calculateEmptyNeighboursValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0, NbP < NbO, Value is (100 * NbO) / Somme.
	% les joueurs ont le même nombre de pions prenables : valeur nulle
	calculateEmptyNeighboursValue(_, _, Value) :- Value is 0.

	% définit si une case donnée a au moins un voisin vide
	hasEmptyNeighbour(Board, Player, Index, Value) :-
    	nth0(Index, Board, Elem),
    	nonvar(Elem),
    	Elem\=Player,
    	Value is 0.
	hasEmptyNeighbour(Board, _, Index, Value) :-
    	nth0(Index, Board, Elem),
    	var(Elem),
    	Value is 0.
	hasEmptyNeighbour(Board, _, Index, Value) :-
    	not(hasEmptyNeighbourAt(Board, Index, -9)),
        not(hasEmptyNeighbourAt(Board, Index, -8)),
        not(hasEmptyNeighbourAt(Board, Index, -7)),
        not(hasEmptyNeighbourAt(Board, Index, -1)),
        not(hasEmptyNeighbourAt(Board, Index, 1)),
        not(hasEmptyNeighbourAt(Board, Index, 7)),
        not(hasEmptyNeighbourAt(Board, Index, 8)),
        not(hasEmptyNeighbourAt(Board, Index, 9)),
        Value is 0, !. 
	hasEmptyNeighbour(_, _, _, Value) :-
    	Value is 1, !.

	% définit si une case donnée a pour voisin Index+Increment une case vide
	hasEmptyNeighbourAt(Board, Index, Increment) :-
    	not(estAuBord(Index, Increment)),
    	CaseToCheck is Index+Increment,
    	nth0(CaseToCheck, Board, Elem),
    	var(Elem), !.


%%% Heuristique stabilité des pions
	% heuristique sur la stabilité des pions, en fonction de la position,
	% des pions du joueur sur le plateau [-100,100]
	% plus la stabilité d'un joueur (par rapport à l'adversaire) est élevée,
	% plus la configuration est intéressante
	stabilityHeuristic(Board, Player, Value) :-
    	% tableau contenant les coefficients de stabilité relatifs aux différentes positions du plateau
    	% plus une valeur est élevée (la plus élevée étant 20, pour les coins, car une fois pris ils ne
    	% peuvent être repris), plus la stabilité de la position est importante
      	StabilityCoef = 
      	[20, -3, 11, 8, 8, 11, -3, 20,
       	 -3, -7, -4, 1, 1, -4, -7, -3,
       	 11, -4,  2, 2, 2,  2, -4, 11,
          8,  1,  2,-3,-3,  2,  1,  8,
          8,  1,  2,-3,-3,  2,  1,  8,
         11, -4,  2, 2, 2,  2, -4, 11,
         -3, -7, -4, 1, 1, -4, -7, -3,
         20, -3, 11, 8, 8, 11, -3, 20],
    	stabilityForPlayer(Board, StabilityCoef, Player, 0, NbP),
    	changePlayer(Player, Opponent),
		stabilityForPlayer(Board, StabilityCoef, Opponent, 0, NbO),
    	calculateStabilityValue(NbP, NbO, Value), !.
    
	% le joueur a plus de stabilité que son adversaire : valeur positive
	calculateStabilityValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0, NbP > NbO, Value is (100 * NbP) / Somme.
	% le joueur a moins de stabilité que son adversaire : valeur négative
	calculateStabilityValue(NbP, NbO, Value) :- Somme is NbP+NbO, Somme\=0, NbP < NbO, Value is -(100 * NbO) / Somme.
	% les joueurs ont une stabilité identique : valeur nulle
	calculateStabilityValue(_, _, Value) :- Value is 0.

    % calcule le nombre de pions prenables (ayant un voisin vide) pour le joueur Player
	stabilityForPlayer(_, _, _, 64, FinalValue) :- FinalValue is 0, !.
	stabilityForPlayer(Board, StabilityCoef, Player, Index, FinalValue) :-
    	Index2 is Index+1,
    	stabilityForPlayer(Board, StabilityCoef, Player, Index2, Value2),
    	getStabilityValue(Board, StabilityCoef, Player, Index, Value), % on récupère la valeur de stabilité de la case
    	FinalValue is Value+Value2, !.
	
	% définit la valeur de stabilité de la case à l'index Index pour le joueur Joueur
	getStabilityValue(Board, StabilityCoef, Player, Index, Value) :-
    	nth0(Index, Board, Elem),
    	nonvar(Elem), 
    	Elem==Player, % on vérifie que le pion appartient au joueur
    	nth0(Index, StabilityCoef, Value), !. % on récupère la valeur de stabilité associée à la case
	getStabilityValue(_, _, _, _, Value) :-
    	Value is 0, !.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
	
%%%%%%%%%%%%%%%%%%%% Artificial intelligence %%%%%%%%%%%%%%%%%%%%
%%% l'IA a le board, et le joueur dont elle se fiche pour l'instant : le 'is' récupère un nombre random (mais on pourrait avoir un truc plus compliqué),
%%% on récupère l'élement à cet endroit, si c'est une variable (donc non unifiée), on arrête la preuve.
% Board : plateau de jeu, NumeroCase : [0,63], Player : 'x' ou 'o'
	ia(Board, NumeroCase, Player) :-
		casesJouables(Board, 0, Player, Liste),
		iaCalcul(Board, NumeroCase, Player,Liste).

	iaCalcul(_, NumeroCase, _,ListeJouable) :-
		length(ListeJouable,0),
		NumeroCase = -1.
	iaCalcul(_, NumeroCase, _,ListeJouable) :-
		length(ListeJouable,N),
		% Repeat propose toujours des choix, toujours vrai : relance toujours la preuve. (Donc on relance à chaque fois la relance de random())
		repeat,
		Index is random(N),
		nth0(Index, ListeJouable, NumeroCase), !.

%%% IA qui choisi la case qui donne le plus de points au tour actuel.
% Board : le plateau, ValeurCase : l'indice de la case choisie par l'IA (sortie), Player : le joueur qui demande à l'IA de jouer.
	iaGreedyMax(Board, NumeroCase, Player) :-
		casesJouables(Board, 0, Player, Liste),
		iaGreedyMaxCalcul(Board, NumeroCase, Player,Liste).

	iaGreedyMaxCalcul(_, NumeroCase, _,ListeJouable) :-
		length(ListeJouable,0),
		NumeroCase = -1.
	iaGreedyMaxCalcul(Board, NumeroCase, Player, ListeJouable) :-
		calculerGains(Board, ListeJouable, ListeGains, Player), % On calcul les gains de la liste passée en paramètre
		maxListe(ListeGains, _, IndiceDuGainMax), % On récupère l'indice du max dans le tableau de gain
		nth0(IndiceDuGainMax, ListeJouable, NumeroCase), !. % On récupère la valeur de la case jouable correspondante
	
%%% IA cherche à maximiser le coup en sommant à plusieurs profondeurs ses gains.
% Board : le plateau, ValeurCase : l'indice de la case choisie par l'IA (sortie), Player : le joueur qui demande à l'IA de jouer.
	iaGreedyMaxDepth(Board, NumeroCase, Player) :-
		casesJouables(Board, 0, Player, Liste),
		iaGreedyMaxDepthCalcul(Board, NumeroCase, Player,Liste).

	iaGreedyMaxDepthCalcul(_, NumeroCase, _,ListeJouable) :-
		length(ListeJouable,0),
		NumeroCase = -1.
	iaGreedyMaxDepthCalcul(Board, MoveOUT, Player, ListeJouable) :-
    	copy_term(Board,BoardTMP),
		evaluateChaqueBrancheJouable(BoardTMP, Player, ListeJouable, MoveOUT, _).


%%% IA qui choisit la case amenant à la configuration la plus intéressante (par rapport à l'heuristique définie dans totalHeuristic)
% Board : le plateau, ValeurCase : l'indice de la case choisie par l'IA (sortie), Player : le joueur qui demande à l'IA de jouer.
	iaHeuristicOneLevel(Board, NumeroCase, Player) :-
		casesJouables(Board, 0, Player, Liste),
		iaHeuristicOneLevelCalcul(Board, NumeroCase, Player, Liste).
		
	iaHeuristicOneLevelCalcul(_, NumeroCase, _,ListeJouable) :-
		length(ListeJouable,0),
		NumeroCase = -1.
	iaHeuristicOneLevelCalcul(Board, NumeroCase, Player, ListeJouable) :-
    	copy_term(Board,BoardTMP),
		getNextConfiguration(BoardTMP, ListeJouable, Player, Values), % On calcule les gains de la liste passée en paramètre
		maxListe(Values, _, IndiceMaxValue), % On récupère l'indice du max dans le tableau de gain
		nth0(IndiceMaxValue, ListeJouable, NumeroCase), !. % On récupère la valeur de la case jouable correspondante
	
	getNextConfiguration(_, [], _, _).
	getNextConfiguration(Board, [HMoves|TMoves], Player, [TotalValue|Values2]) :-
		getNextConfiguration(Board, TMoves, Player, Values2),
		playMove(Board, HMoves, BoardAfterMove, Player), % On joue le coup
    	% On calcule la valeur de l'heuristique pour la configuration
		totalHeuristic(BoardAfterMove, Player, TotalValue).

		
%%% IA qui choisit la case amenant à la configuration la plus intéressante (par rapport à l'heuristique définie dans totalHeuristic)
% en allant à une profondeur NbLevels dans l'arbre des possibilités
% Board : le plateau, ValeurCase : l'indice de la case choisie par l'IA (sortie), Player : le joueur qui demande à l'IA de jouer,
% NbLevels : profondeur de recherche dans l'arbre des possibilités
	iaHeuristicNlevels(Board, NumeroCase, Player, NbLevels) :-
		casesJouables(Board, 0, Player, Liste), % on récupère la liste des cases jouables
		iaHeuristicNlevelsCalcul(Board, NumeroCase, Player, Liste, NbLevels).

	iaHeuristicNlevelsCalcul(_, NumeroCase, _, ListeJouable, _) :-
		length(ListeJouable,0),
		NumeroCase = -1.
    iaHeuristicNlevelsCalcul(Board, MoveOUT, Player, ListeJouable, NbLevels) :-
	copy_term(Board,BoardTMP),
		checkAllPossibilities(BoardTMP, Player, ListeJouable, MoveOUT, _, NbLevels).

%%% Cherche à itérer sur chaque branche jouable = pour chaque case jouable
% Board : le plateau de jeu, Player : le joueur que l'IA cherche à faire gagner, ListeJouable : la liste des cases jouables du plateau initial,
% MoveOUT : (sortie) : le move à choisir, ScoreOUT : (sortie) le score à attendre du move choisi
	% Condition d'arrêt si on a fait toutes les cases jouables, le score sera nul, le Move sera -1. (on passe)
	checkAllPossibilities(_, _, [], -1, -1000000, _).
	checkAllPossibilities(Board, Player, [FirstMove|ListeJouable], MoveOUT, ScoreOUT, NbLevels) :-
	copy_term(Board,BoardTMP),
		checkOnePossibility(BoardTMP, Player, Player, FirstMove, ScoreThisBranch, NbLevels),		% On prend le premier move possible, on évalue cette branche. On obtient le score de cette branche.
		checkAllPossibilities(Board, Player, ListeJouable, ActualMove, ActualScore, NbLevels),		% On lance la récursivité, pour chercher si les scores des branches suivantes.
		updateValueForMAX(ScoreThisBranch, FirstMove, ActualScore, ActualMove, ScoreOUT, MoveOUT).		% Si Score de la branche actuelle est plus grand que le score des autres branches, on garde le move de cette branche.

%%% Permet de donner le score de la branche, de manière récursive à un niveau de profondeur NbLevels
% Board : le plateau, Player : le joueur qui cherche son coup, FirstMove : le premier coup que l'on décide de jouer (de la part de Player),
% NbLevels : la profondeur à laquelle rechercher dans l'arbre,
% PlayerHeuristique : le joueur pour lequel on cherche la valeur de l'heuristique (ne change pas),
% ScoreFinal : (sortie) le score calculé pour cette branche
	checkOnePossibility(_, _, _, _, ScoreFinal, 0) :- ScoreFinal is 0, !.
	checkOnePossibility(Board, PlayerHeuristique, Player, FirstMove, ScoreFinal, NbLevels) :-
		playMove(Board, FirstMove, BoardAfterFirstMove, Player),		% On joue le coup
	NbLevels2 is NbLevels - 1,	% On décrémente NbLevels
	changePlayer(Player, Player2),	% On récupère l'autre joueur
	% On calcule la valeur de l'heuristique de la configuration actuelle
	totalHeuristic(BoardAfterFirstMove, PlayerHeuristique, TotalValue),
	% On peut appeler l'IA greedyMax, qui choisit le meilleur coup suivant (de l'autre joueur)
	iaGreedyMax(BoardAfterFirstMove, NumberMove, Player2),
	% On va à une profondeur plus importante
	checkOnePossibility(BoardAfterFirstMove, PlayerHeuristique, Player2, NumberMove, ScoreFinal2, NbLevels2),
	ScoreFinal is ScoreFinal2+TotalValue.		% On calcule l'heuristique		
		
		
%IA Gloutonne qui utilise un plateau de jeu coefficienté statique pour orienter plus ses choix de jeu
%Board: le plateau,ValuedBoard : le tableau contenant l'ensemble des valeurs des coefficients de gain des cases, ValeurCase : l'indice de la case choisie par l'IA ( sortie ), Player : le joueur qui demande à l'IA de jouer.
  iaGreedyValuedMax(Board,NumeroCase,Player):-
      casesJouables(Board, 0, Player, Liste), % On récupère les cases jouable ( dans "Liste" )
      ValuedBoard=[10,-5, 5, 4, 4, 5,-5,10,
                   -5,-5, 3, 2, 2, 3,-5,-5,
                    5, 3, 4, 1, 1, 4, 3, 5,
                    4, 2, 1, 1, 1, 1, 2, 4,
                    4, 2, 1, 1, 1, 1, 2, 4,
                    5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
      calculerGainValued(Board, ValuedBoard, Liste, ListeGainValued, Player), % On calcule les valeurs de gain des cases jouables de la liste passée en paramètre
      maxListe(ListeGainValued, _, IndiceDeGainValuedMax), % On récupère l'indice du max dans la liste des gains
      nth0(IndiceDeGainValuedMax, Liste, NumeroCase), !. % On récupère la valeur de la case jouable correspondante

%%%%%%%% Clauses utiles pour l'IA Gloutonne à heuristique comportant une valuation des cases du plateau de jeu %%%%%%%%%

%%% Cherche à itérer sur chaque branche jouable = pour chaque case jouable
% Board : le plateau de jeu,ValuedBoard : le plateau représentant les coefficients de gain de chaque case du plateau de jeu,Queue : Liste des cases dont le gain doit être calculé, Player : le joueur que l'IA cherche à faire gagner,
% ListeGainsValuedOUT : (sortie) Liste des gains associés aux cases jouables de la liste Queue
  calculerGainValued(_,__,[],[],___).
  calculerGainValued(Board,ValuedBoard, [NumeroCaseAEvaluer|Queue], [GainValuedOut|ListeGainsValuedOUT], Player) :-
      calculerGainValuedUneCase(Board,ValuedBoard, NumeroCaseAEvaluer, Player,GainValuedOut), %On calcule le gain de la case "NumeroCaseAEvaluer" du Board. 
      calculerGainValued(Board,ValuedBoard, Queue, ListeGainsValuedOUT, Player),!. %On relance la récursivité pour calculer le gain de la case à évaluer suivante

%%% Calcule le gain total rapporté par une case au joueur Player s'il joue son pion sur cette case du plateau de jeu
% Board : le plateau de jeu, ValuedBoard : le plateau représentant les coefficients de gain de chaque case du plateau de jeu, IndiceCaseAEvaluer : Indice de la case du plateau de jeu dont le gain total doit être calculé, Player : le joueur que l'IA cherche à faire gagner,
% GainValuedOut : (sortie) Gain total associé à la case à étudier dont l'indice IndiceCaseAEvaluer est entré en paramètre
  calculerGainValuedUneCase(Board, ValuedBoard,IndiceCaseAEvaluer, Player,GainValuedOut):-
      calculerGainValuedPionsManges(Board, ValuedBoard,IndiceCaseAEvaluer, Player,GainValuedPions), %On calcule le gain provenant des pions mangés par le joueur Player en cas de jeu sur la case passée en paramètre
      compare(=,GainValuedPions,0), %Si aucun pion n'est mangé alors le gain sera forcément nul car le pion ne pourra pas être joué sur la case passée en paramètre
      GainValuedOut = 0,!.
  calculerGainValuedUneCase(Board, ValuedBoard,IndiceCaseAEvaluer, Player,GainValuedOut):-
      calculerGainValuedPionsManges(Board, ValuedBoard,IndiceCaseAEvaluer, Player,GainValuedPions), %On calcule le gain provenant des pions mangés par le joueur Player en cas de jeu sur la case passée en paramètre
      nth0(IndiceCaseAEvaluer,ValuedBoard,GainValuedCase), %On récupère le gain relatif à l'emplacement où le joueur pose son pion
      GainValuedOut is GainValuedPions+GainValuedCase. %On obtient le gain total relatif à la case en sommant les deux gains précédents

%%% Calcule le gain total de l'ensemble des pions adverses mangés obtenu par le joueur Player s'il joue son pion sur la case du plateau de jeu passée en paramètre
% Board : le plateau de jeu, ValuedBoard : le plateau représentant les coefficients de gain de chaque case du plateau de jeu, IndiceCaseAEvaluer : Indice de la case du plateau de jeu dont le gain total doit être calculé, Player : le joueur que l'IA cherche à faire gagner,
% GainValuedPions : (sortie) Gain total associé aux pions mangés par le joueur en cas de jeu sur la case à étudier dont l'indice IndiceCaseAEvaluer est entré en paramètre
  calculerGainValuedPionsManges(Board, ValuedBoard,IndiceCaseAEvaluer, Player,GainValuedPions):-
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      -1, Player, GainValuedPions1), %Calcul du gain dans la direction horizontale vers la gauche du plateau
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      1, Player, GainValuedPions2), %Calcul du gain dans la direction horizontale vers la droite du plateau
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      8, Player, GainValuedPions3), %Calcul du gain dans la direction verticale vers le bas du plateau
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      -8, Player, GainValuedPions4), %Calcul du gain dans la direction verticale vers le haut du plateau
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      7, Player, GainValuedPions5), %Calcul du gain dans la direction diagonale inférieure gauche du plateau
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      -7, Player, GainValuedPions6), %Calcul du gain dans la direction diagonale supérieure droite du plateau
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      9, Player, GainValuedPions7), %Calcul du gain dans la direction diagonale inférieure droite du plateau
      calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer, 
      -9, Player, GainValuedPions8), %Calcul du gain dans la direction diagonale supérieure gauche du plateau
      GainValuedPions is GainValuedPions1+GainValuedPions2+GainValuedPions3+GainValuedPions4+GainValuedPions5+GainValuedPions6+GainValuedPions7+GainValuedPions8. %Somme des gains relatifs aux pions adverses mangés dans toutes les directions
    
%%% Calcule le gain total de l'ensemble des pions adverses mangés suivant une direction obtenu par le joueur Player s'il joue son pion sur la case du plateau de jeu passée en paramètre
% Board : le plateau de jeu, ValuedBoard : le plateau représentant les coefficients de gain de chaque case du plateau de jeu, IndiceCaseAEvaluer : Indice de la case du plateau de jeu dont le gain total doit être calculé, Increment : entier relatif représentant la direction d'étude de gain, Player : le joueur que l'IA cherche à faire gagner,
% GainValuedDirectionOUT : (sortie) Gain total associé aux pions mangés dans la direction indiquée par Increment par le joueur en cas de jeu sur la case à étudier dont l'indice IndiceCaseAEvaluer est entré en paramètre   
  calculerGainValuedUneDirection(Board,_, IndiceCaseAEvaluer, Increment, Player, GainValuedDirectionOUT):-
      subBoardRecursif(Board,IndiceCaseAEvaluer,Increment, L1), %On crée une sublist du plateau de jeu depuis la case étudiée vers le bord du plateau dans la direction indiquée par Increment
      subListJusqueValINCLUS(L1,Player,L2), %On récupère la sous liste (de L1) jusqu'à la première case "vide" ou la première case du joueur Player
      \+member(Player,L2), %On vérifie si aucun pion du joueur Player n'est dans la liste pour savoir si la case est non-jouable.
      GainValuedDirectionOUT = 0,!. % Cette branche ne donnera donc aucun point (pas jouable)
  calculerGainValuedUneDirection(Board,ValuedBoard, IndiceCaseAEvaluer,Increment, Player, GainValuedDirectionOUT):-
      subBoardRecursif(Board,IndiceCaseAEvaluer,Increment, L1), %On crée une sublist du plateau de jeu depuis la case étudiée vers le bord du plateau dans la direction indiquée par Increment
      subListJusqueValINCLUS(L1,Player,L2), %On récupère la sous liste (de L1) jusqu'à la première case "vide" ou la première case du joueur Player
      member(Player,L2), %On vérifie si la case est jouable, en vérifiant la présence d'un pion du joueur Player dans la sous-liste
      length(L2,SizeL2), % On récupère la longueur totale de la sous-liste obtenue précédemment
      valAbsBoard(ValuedBoard,AbsoluteValuedBoard), % On récupère les coefficients absolus du tableau valué (valeurs des coefficients positifs pour tous les pions volés à l'adversaire)
      subBoardRecursif(AbsoluteValuedBoard,IndiceCaseAEvaluer,Increment, L3), %On récupère la sublist du plateau valué correspondant à la sublist du plateau de jeu récupéré précédemment
      SizeL2MoinsUN is SizeL2-1, % On ne considère que les pions adverses
      subValuedList(L3,SizeL2MoinsUN,L4), %On récupère la liste des gains de chaque pion adverse mangé dans la direction étudiée    
      sum_list(L4, GainValuedDirectionOUT),!. % Somme des gains de chaque pion mangé dans la direction étudiée

%%% Récupère la sous-liste L2 de taille N depuis le début de la liste L1 passée en paramètre
  subValuedList(_,0,[]).
  subValuedList([H|L1],N,[H|L2]):- Y is N-1, subValuedList(L1,Y,L2),!.

%%% Récupère le plateau AbsBoard dont les valeurs correspondent aux valeurs absolues du contenu du plateau T passé en paramètre
  valAbsBoard([],[]).
  valAbsBoard([H|T],AbsBoard):-compare(<,H,0),Y is -H,append([Y],NewAbsBoard,AbsBoard),valAbsBoard(T,NewAbsBoard),!.
  valAbsBoard([H|T],AbsBoard):-append([H],NewAbsBoard,AbsBoard),valAbsBoard(T,NewAbsBoard),!.

%%%%%%%% Fin des clauses utiles pour l'IA Gloutonne à heuristique comportant une valuation des cases du plateau de jeu %%%%%%%%%

%%%%%%% DEBUT

%%% IA Monte Carlo : Descente en profondeur de manière random jusqu'à la fin de la partie un grand nombre de fois pour déterminer quel coup permet de gagner avec le plus de probabilité
	iaMonteCarlo(Board, NumeroCase, Player) :-
    	casesJouables(Board, 0, Player, Liste),
    	iaMCCalcul(Board, NumeroCase, Player, Liste), !.
    	
    iaMCCalcul(_, NumeroCase, _, Liste) :- 
    	length(Liste, 0),
    	NumeroCase = -1.
	
	iaMCCalcul(_, NumeroCase, Player, Liste) :-
    	length(Liste, NbCoups),
    	creerListeN(NbCoups, LJoues),
    	creerListeN(NbCoups, LGagnes),
    	iaMCRepeat(50, Player, Liste, LJoues, LGagnes),
    	lJoues(FLJoues),
		lGagnes(FLGagnes),
    	calculRatio(FLJoues, FLGagnes, LRatio),
    	maxListe(LRatio, _, Index),
    	nth0(Index, Liste, NumeroCase).
    	


	iaMCRepeat(0, _, _, LJoues, LGagnes) :- saveState(LJoues, LGagnes), boardMC(B), retractall(boardMC(B)), !.
    iaMCRepeat(NbIter, Player, Liste, Ljoues, LGagnes) :-
    	NNbIter is NbIter-1,
    	retractall(boardMC(_)),
    	board(Board), % On récupère le board actuel
    	ia(Board, Move,Player), % ask the AI for a move, that is, an index for the Player % choix du mouvement
        nth0(Move, Board, Player),
    	nth0(Index, Liste, Move),
    	addOneListe(Index, Ljoues, NLJoues),
	    playMove(Board,Move,NewBoard,Player), % Play the move and get the result in a new Board % Fait le mouvement, unification sur l'ancien plateau
		assert(boardMC(NewBoard)), % Remove the old board from the KB and store the new one % Suppressionde l'ancien plateau de la mémoire, garde le nouveau
	    changePlayer(Player,NextPlayer), % Change the player before next turn %
    	playMC(NextPlayer), % Let's PLAY !!!!!!!!!!!!!!
		majWin(Index, Player, LGagnes, NLGagnes),
		iaMCRepeat(NNbIter, Player, Liste, NLJoues, NLGagnes).

    	
    
%%% Nécessaire pour IA MC
	
	calculRatio([],[],[]).
	calculRatio([0|Joue], [_|Gagne], [0|Ratio]):- !, calculRatio(Joue, Gagne, Ratio).
	calculRatio([HJ|Joue], [HG|Gagne], [HR|Ratio]):- HR is HG/HJ, calculRatio(Joue, Gagne, Ratio).

	majWin(_, Player, LGagnes, LGagnes):-%adversaire gagne
    	boardMC(FinalBoard),
    	changePlayer(Player,NextPlayer),
    	winner(FinalBoard, NextPlayer).
    
	majWin(Index, Player, LGagnes, NLGagnes):-%joueur gagne
    	boardMC(FinalBoard),
		winner(FinalBoard, Player),
		addOneListe(Index, LGagnes, NLGagnes).
	majWin(_, _, LGagnes, LGagnes).
	

	saveState(LJoues, LGagnes):- retract(lJoues(LJoues)), assert(lJoues(LJoues)), retract(lGagnes(LGagnes)), assert(lGagnes(LGagnes)), !.
	saveState(LJoues, LGagnes):- assert(lJoues(LJoues)), assert(lGagnes(LGagnes)).
%%% Crée une liste de taille N remplie de 0
    creerListeN(0, []).
	creerListeN(N, Liste) :- NN is N-1, creerListeN(NN, NListe), Liste = [0|NListe], !. 
    
	addOneListe(0, [H|T], [NH|T]) :- NH is H+1. 
	addOneListe(Index, [H|T], [H|NT]) :- NIndex is Index-1, addOneListe(NIndex, T, NT), !.
    


	playMC(_):- gameoverMC(_), !.
	playMC(Player):-
		boardMC(Board), % instanciate the board from the knowledge base  % Récupère le board dans les faits du prog.
    	%displayBoardMC, % print it % Affichage du plateau
    	ia(Board, Move, Player), % ask the AI for a move, that is, an index for the Player % choix du mouvement
	    playMove(Board,Move,NewBoard,Player), % Play the move and get the result in a new Board % Fait le mouvement, unification sur l'ancien plateau
		applyItMC(Board, NewBoard), % Remove the old board from the KB and store the new one % Suppressionde l'ancien plateau de la mémoire, garde le nouveau
	    changePlayer(Player,NextPlayer), % Change the player before next turn %
        playMC(NextPlayer).
	
	applyItMC(Board,NewBoard) :- retract(boardMC(Board)), assert(boardMC(NewBoard)).

	gameoverMC(Winner) :- boardMC(Board), !, isBoardFull(Board), winner(Board, Winner), !.

%%% Print the value of the board at index N:
% if its a variable, print ? and x or o otherwise.
	printValMC(N) :- boardMC(B), nth0(N,B,Val), var(Val), write('?'), !.
% Récupère plateau en mémoire, Vrai si val est la valeur de la liste B de la Nième position, si c'est une variable (non unifiée), on print, on coupe pour le pas afficher en double.
	printValMC(N) :- boardMC(B), nth0(N,B,Val), write(Val).

%%% Display the board
	displayBoardMC:-
		writeln('*----------*'),
		printValMC(0),printValMC(1),printValMC(2),printValMC(3),printValMC(4),printValMC(5),printValMC(6),printValMC(7),writeln(''),
		printValMC(8),printValMC(9),printValMC(10),printValMC(11),printValMC(12),printValMC(13),printValMC(14),printValMC(15),writeln(''),
		printValMC(16),printValMC(17),printValMC(18),printValMC(19),printValMC(20),printValMC(21),printValMC(22),printValMC(23),writeln(''),
		printValMC(24),printValMC(25),printValMC(26),printValMC(27),printValMC(28),printValMC(29),printValMC(30),printValMC(31),writeln(''),
		printValMC(32),printValMC(33),printValMC(34),printValMC(35),printValMC(36),printValMC(37),printValMC(38),printValMC(39),writeln(''),
		printValMC(40),printValMC(41),printValMC(42),printValMC(43),printValMC(44),printValMC(45),printValMC(46),printValMC(47),writeln(''),
		printValMC(48),printValMC(49),printValMC(50),printValMC(51),printValMC(52),printValMC(53),printValMC(54),printValMC(55),writeln(''),
		printValMC(56),printValMC(57),printValMC(58),printValMC(59),printValMC(60),printValMC(61),printValMC(62),printValMC(63),writeln(''),
		writeln('*----------*').
%%%%%%% FIN


%%%%%%% MCTS by Benji

	% Jouer une partie aléatoirement jusqu'à la fin depuis une configuration @Board donnée, retourne le @Winner
	playSilentRandomTurn(Board, _, Winner) :-     		%% Jouer un tour : Fin d'une partie
    	isBoardFull(Board), 								% On vérifie qu'aucun mouvement n'est possible
    	winner(Board, Winner), !. 							% On détérmine le gagnant
		
	playSilentRandomTurn(Board, Player, Winner):-		%% Jouer un tour : On peut encore faire un mouvement
		ia(Board, Move, Player), 							% On choisit le coup via IA Random
	    playMove(Board,Move,NewBoard,Player), 				% On applique le coup
	    changePlayer(Player,NextPlayer), 					% On choisit le prochain joueur
        playSilentRandomTurn(NewBoard, NextPlayer, Winner). % On passe au tour suivant
		
	iaMCTS(Board, CaseNumber, Player, Budget) :-							%% Choisir un coup via IA MCTS
		casesJouables(Board, 0, Player, MoveList),								% On obtient la liste mouvements jouables
    	length(MoveList, MoveListLength),										% On obtient le nombre de mouvements jouables
    	BranchBudget is div(Budget, MoveListLength),							% On calcul le budget alloué pour estimer un mouvement
		iaMCTSEachBranch(Board, Player, MoveList, Results, BranchBudget),		% On estime chaque mouvement
    	maxListe(Results, _, Index),											% On trouve le mouvement le mieux estimé
    	nth0(Index, MoveList, CaseNumber), !.									% On renvoit la case associée au meilleur mouvement

	iaMCTSEachBranch(_, _, [], _, _).												%% Estimer chaque mouvement possible : Fin itération
	iaMCTSEachBranch(Board, Player, [Branch|Branchs], Result, BranchBudget) :- 		%% Estimer chaque mouvement possible : Pendant itération
    	iaMCTSComputeBranch(Board, Player, Branch, BranchResult, BranchBudget), 		% On estime le mouvement
    	append([BranchResult], SubResult, Result), 										% On compile le résultat de l'estimation
    	iaMCTSEachBranch(Board, Player, Branchs, SubResult, BranchBudget).				% On estime la branche suivante

	iaMCTSComputeBranch(Board, Player, Branch, Result, BranchBudget) :-     		%% Estimer un mouvement
    	copy_term(Board, TmpBoard),														% On clone le contexte du plateau
    	playMove(TmpBoard,Branch,TmpNewBoard,Player),									% On joue virtuellement le coup
    	iaMCTSComputeBranchIteration(TmpNewBoard, Player, BranchBudget, Result).		% On estime les parties gagnantes descendantes
	
	iaMCTSIsVictory(Winner, Player, 1) :- Winner == Player, !.		%% Détérminer que le statut du joueur : victorieux
	iaMCTSIsVictory(Winner, Player, 0) :- Winner \== Player, !.		%% Détérminer que le statut du joueur : perdant

	iaMCTSComputeBranchIteration(_, _, 0, 0).								%% Estimer un nombre de parties descendantes gagnantes : Plus de partie à jouer
	iaMCTSComputeBranchIteration(Board, Player, Iterator, Result) :-     	%% Estimer un nombre de parties descendantes gagnantes : On joue une partie 	  
    	copy_term(Board, TmpBoard),												% On clone le contexte du plateau
    	changePlayer(Player, AdversePlayer),									% On détérmine le joueur adverse
    	playSilentRandomTurn(TmpBoard, AdversePlayer, Winner),  				% On joue une partie aléatoire 	
    	iaMCTSIsVictory(Winner, Player, Score),									% On détérmine si le joueur aurait gagné ou perdu cette partie
    	SubIterator is Iterator-1,												% On avance dans l'itération
    	iaMCTSComputeBranchIteration(Board, Player, SubIterator, SubResult),    % On lance l'estimation d'une nouvelle partie aléatoire
    	Result is Score+SubResult.												% On cumule le nombre de parties gagnées

%%%%%%% End of MCTS


%%% Cherche à itérer sur chaque branche jouable = pour chaque case jouable
% Board : le plateau de jeu, Player : le joueur que l'IA cherche à faire gagner, ListeJouable : la liste des cases jouables du plateau initial,
% MoveOUT : (sortie) : le move à choisir, ScoreOUT : (sortie) le score à attendre du move choisi
	% Condition d'arrêt si on a fait toutes les cases jouables, le score sera nul, le Move sera -1. (on passe)
	evaluateChaqueBrancheJouable(_, _, [], -1, 0). 
	evaluateChaqueBrancheJouable(Board, Player, [FirstMove|ListeJouable], MoveOUT, ScoreOUT) :-
    	copy_term(Board,BoardTMP),
		evaluateBranch(BoardTMP, Player, FirstMove, ScoreThisBranch),		% On prend le premier move possible, on évalue cette branche. On obtient le score de cette branche.
		evaluateChaqueBrancheJouable(Board, Player, ListeJouable, ActualMove, ActualScore),		% On lance la récursivité, pour chercher si les scores des branches suivantes.
		updateValueForMAX(ScoreThisBranch, FirstMove, ActualScore, ActualMove, ScoreOUT, MoveOUT ). 		% Si Score de la branche actuelle est plus grand que le score des autres branches, on garde le move de cette branche.
	
%%% Permet de donner le score de la branche, en considérant un premier move commandé à nous, 1 move ennemi et 1 move à nous. Meilleur score.
% Board : le plateau, Player : le joueur qui cherche son coup, FirstMove : le premier coup que l'on décide de jouer (de la part de Player),
% ScoreFinal : (sortie) le score calculé pour cette branche
	evaluateBranch(Board, Player, FirstMove, ScoreFinal) :-
		calculerGainUneCase(Board, FirstMove, Player, FirstScore), 		% On calcul le gain ami sur ce premier coup
		playMove(Board, FirstMove, BoardAfterFirstMove, Player),		% On joue ce premier coup
		changePlayer(Player, Opponent),									% On récupère l'opposant
		iaGreedyMax(BoardAfterFirstMove, NumberMoveOpponent, Opponent), % On peut appeller l'IA greedyMax, qui choisit le meilleur coup à 0 profondeur, pour choisir le coup ennemi.
		calculerGainUneCase(BoardAfterFirstMove, NumberMoveOpponent, Opponent, GainOpponent),% On calcule le gain ennemi sur ce coup
		playMove(BoardAfterFirstMove, NumberMoveOpponent, BoardAfterOpponentMove, Opponent), % Joue le meilleur coup pour l'adversaire, et on créé le plateau de ce coup
		iaGreedyMax(BoardAfterOpponentMove, NumeroMovePlayer, Player),  % On peut appeller l'IA greedyMax, qui choisit le meilleur coup à 0 profondeur, pour choisir notre futur meilleur coup.
		calculerGainUneCase(BoardAfterOpponentMove, NumeroMovePlayer, Player, GainPlayer), 		% On calcule le gain ennemi sur ce coup
		ScoreFinal is FirstScore+GainPlayer-GainOpponent. 		% On calcul le score de la branche (maximisation de nos gains, minimisation du gain de l'opposant)
	evaluateBranch(_, _, _, 0).
%%% Correspond à une "IF" : si "ValueINA" est inférieur à "ValueINB" alors ValueOUT prend la valeur de "ValueINB", sinon "ValueINA"
%%% Correspond à une fonction "max"
% ValueINA: la valeur à comparer numéro 1, InfoINA : l'information à transmettre liée à la valeur N°1, ValueINB : la valeur à comparer numéro 2,
% InfoINB: l'information à transmettre liée à la valeur N°2, ValueOUT : valeur N°1 si valeur N°1 > ValeurN°2, ValeurN°2 sinon (sortie),
% InfoOUT : info N°1 si valeur N°1 > ValeurN°2, info N°2 sinon (sortie)
	updateValueForMAX(ValueINA, _, ValueINB, InfoINB, ValueOUT, InfoOUT) :-
		ValueINA < ValueINB,
		ValueOUT is ValueINB,
		InfoOUT is InfoINB.
	updateValueForMAX(ValueINA, InfoINA, ValueINB, _, ValueOUT, InfoOUT) :-
		ValueINA > ValueINB,
		ValueOUT is ValueINA,
		InfoOUT is InfoINA.
	updateValueForMAX(ValueINA, InfoINA, ValueINB, _, ValueOUT, InfoOUT) :-
		ValueINA == ValueINB,
		ValueOUT is ValueINA,
		InfoOUT is InfoINA.
	
	
%%%%%%%%%%%%%%%%%%%% Clauses utiles pour une IA MIN MAX %%%%%%%%%%%%%%%%%%%%
%%% Clause qui donne la valeur max et son indice dans une liste
% Liste : la liste dans laquelle on chercher, ValueMax : la valeur max trouvée (sortie), Indice : l'indice de la valeur max dans la liste (sortie)
	maxListe(Liste, ValueMax, Indice) :-
		max_list(Liste,ValueMax), %On récupère la valeur max
	nth0(Indice, Liste, ValueMax). %On trouve son indice

%%% Clause qui donne le max et son indice dans un tableau
% Board : le plateau de jeu, Liste : la liste des indices pour lesquels ont veut connaître les gains associés,
% ListeGains : la liste des gains associés (même ordre) que la Liste des cases à tester, Index : l'indice de la case de la Liste à tester par lequel
% commencer (0 par défaut pour démarrer la récursion), Player : le joueur pour lequel on calcul les gains
	calculerGains(_,[],[],_).
	calculerGains(Board, [NumeroCaseAEvaluer|Queue], [GainOut|ListeGainsOUT], Player) :-
		calculerGainUneCase(Board, NumeroCaseAEvaluer, Player,GainOut), %On calcul le gain de la case "NumeroCaseAEvaluer" du Board.
		calculerGains(Board, Queue, ListeGainsOUT, Player),!. %On relance la récursivité

%%% Clause qui calcule le gain d'un coup posé dans une case, pour un joueur donné.
% Board : le plateau de jeu, IndiceCaseAEvaluer : le N° de la case où il faut évaluer le gain potentiel, Player : le joueur qui pourrait jouer à cet emplacement,
% GainOut (sortie) : la valeur potentiel de gain calculée.
	calculerGainUneCase(Board, IndiceCaseAEvaluer ,Player,GainOut) :-
		% Pour chaque direction, on calcule le gain
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, 1, Player, GainOUT1),
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, -1, Player, GainOUT2),
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, 8, Player, GainOUT3),
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, -8, Player, GainOUT4),
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, 7, Player, GainOUT5),
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, -7, Player, GainOUT6),
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, 9, Player, GainOUT7),
		calculerGainUneDirection(Board, IndiceCaseAEvaluer, -9, Player, GainOUT8),
		% On somme en résultat final
		GainOut is GainOUT1+GainOUT2+GainOUT3+GainOUT4+GainOUT5+GainOUT6+GainOUT7+GainOUT8,!.

%%% Clause qui calcule le gain d'un coup posé dans une case dans une direction donnée, pour un joueur donné.
% Board : le plateau de jeu, IndiceInitial : l'index de la case où on considère le jeu, Incrément : la direction où on regarde le gain (+1,-1,..), Player, GainIN :
	calculerGainUneDirection(Board, IndiceCaseAEvaluer, Increment, Player, GainOUT) :-
		% On crée une sublist depuis la case du cran de droite, pour aller au bord
		subBoardRecursif(Board,IndiceCaseAEvaluer,Increment, L1),
		% On récupère la sous liste (de L1) jusqu'à la première case "vide" ou la première case à nous
		subListJusqueValINCLUS(L1,Player,L2),
		% On vérifie si on a bien un jeton dans la liste, donc la case est jouable.
		member(Player,L2),
		% On récupère la "valeur" d'un jeton opposant
		changePlayer(Player,Opposant),
		% Calcul du nombre de case du type "Opponent" dans la liste en paramètre
		nbOfPoints(L2,Opposant,GainOUT),!.
	calculerGainUneDirection(Board, IndiceCaseAEvaluer, Increment, Player, GainOUT) :-
		% On crée une sublist depuis la case du cran de droite, pour aller au bord
		subBoardRecursif(Board,IndiceCaseAEvaluer,Increment, L1),
		% On récupère la sous liste (de L1) jusqu'à la première case "vide" ou la première case à nous
		subListJusqueValINCLUS(L1,Player,L2),
		% On vérifie si on a bien aucun jeton dans la liste, donc la case est non-jouable.
		\+member(Player,L2),
		% Cette branche ne donnera donc aucun point (pas jouable)
		GainOUT = 0.

	
%%%%%%%%%%%%%%%%%%%% Clauses utiles pour obtenir liste des coups jouables pour un joueur %%%%%%%%%%%%%%%%%%%%
%%% Coup à droite est il possible ? (Ps sortir du tableau, il y a bien un pion ennemi qui a une case vide à côté)
%%% On veut qu'il nous sorte toutes les valeurs de NewINDEX jouable à patir de la case INDEX.
% Board : le plateau de jeu, IndexCaseCourante : la case par laquelle on commence la recherche des cases jouables (0),
% Player : le joueur pour lequel on recherche les cases jouables, ListeCoupsJouables : la liste des coup qui peuvent être joué par le jour (sortie)
	casesJouables(_,64,_,[]).
	casesJouables(Board, IndexCaseCourante, Player, ListCoupsJouables) :-
		coup(Board, IndexCaseCourante, Player),
		append([IndexCaseCourante],NewListCoupsJouables,ListCoupsJouables),
		% On incrémente pour aller voir à la case suivante
		IndexSuivant is IndexCaseCourante+1,
		casesJouables(Board, IndexSuivant, Player, NewListCoupsJouables), !.
	casesJouables(Board, IndexCaseCourante, Player, ListCoupsJouables) :-
		% On incrémente pour aller voir à la case suivante
		IndexSuivant is IndexCaseCourante+1,
		casesJouables(Board, IndexSuivant, Player, ListCoupsJouables), !.

%%% ==> On veut qu'il nous dise true si un coup dans la case Index est jouable, peu importe la case, pour ce player et ce board
%%% Note : on vérifie les direction pour éviter des mauvaises détections.
%%% Note, la ligne d'au dessus n'est pas prise en compte.
% Board : le plateau de jeu, index : l'index de la case pour laquelle on veut savoir si elle est jouable, Player : le joueur qui doit hypothétiquement jouer à cette case
	coup(Board, Index, Player) :-
		NewIndex is Index-1,
		coordValtoXY(X,_,Index), % On récupère les coordonnées de la case actuelle.
		X \== 0, % Si on est sur le bord gauche et qu'on va à gauche, on s'arrête
		licite(Board, Index, NewIndex,Player),!. % Ennemi à droite ?
	coup(Board, Index, Player) :-
		NewIndex is Index+1,
		coordValtoXY(X,_,Index), % On récupère les coordonnées de la case actuelle.
		X \== 7, % Si on est sur le bord droite et qu'on va à droite, on s'arrête
		licite(Board, Index, NewIndex,Player),!. % Ennemi à droite ?
	coup(Board, Index, Player) :-
		NewIndex is Index-8,
		licite(Board, Index, NewIndex,Player),!. % Ennemi en haut ?
	coup(Board, Index, Player) :-
		NewIndex is Index+8,
		licite(Board, Index, NewIndex,Player),!. % Ennemi en bas ?
	coup(Board, Index, Player) :-
		NewIndex is Index-9,
		coordValtoXY(X,_,Index), % On récupère les coordonnées de la case actuelle.
		X \== 0, % Si on est sur le bord gauche et qu'on va à gauche, on s'arrête
		licite(Board, Index, NewIndex,Player),!. % Ennemi en haut à gauche ?
	coup(Board, Index, Player) :-
		NewIndex is Index-7,
		coordValtoXY(X,_,Index), % On récupère les coordonnées de la case actuelle.
		X \== 7, % Si on est sur le bord droite et qu'on va à droite, on s'arrête
		licite(Board, Index, NewIndex,Player),!. % Ennemi en haut à droite ?
	coup(Board, Index, Player) :-
		NewIndex is Index+9,
		coordValtoXY(X,_,Index), % On récupère les coordonnées de la case actuelle.
		X \== 7, % Si on est sur le bord droite et qu'on va à droite, on s'arrête
		licite(Board, Index, NewIndex,Player),!. % Ennemi en bas à droite ?
	coup(Board, Index, Player) :-
		NewIndex is Index+7,
		coordValtoXY(X,_,Index), % On récupère les coordonnées de la case actuelle.
		X \== 0, % Si on est sur le bord gauche et qu'on va à gauche, on s'arrête
		licite(Board, Index, NewIndex,Player),!. % Ennemi en bas à gauche ?

%%% Coup est-il licite ? (La première case est-elle vide ? La case à côté a-t-elle un ennemi ? A-t-on un pion bien placé pour que la case puisse être utilisée ? => jouable)
%%% Le plateau de jeu est connu, NewIndex pointe sur une case vide (potentiellement), Index pointe sur une case ennemi (potentiellement),
%%% (Increment donne la direction,) Player donne le type du joueur
% Board : le plateau, NewIndex : index de la case vide (où on veut potentiellement jouer),
% Index : Index d'une case ennemi adjacente à la case jouable, qui donne la direction dans laquelle on veut regarder, Player : le joueur
	licite(Board,NewIndex,Index,Player) :-
		nth0(Index,Board,OriginalVal), % On récupère la valeur de la case sur la case initiale
		nth0(NewIndex, Board, Val), % On récupère la valeur présente sur la case cible
		var(Val), % Si la case cible c'est une variable, donc PAS un des deux joueurs = une case vide, elle pourrait être jouable
		changePlayer(Player,Opposant), % On récupère la "valeur" d'un jeton opposant
		OriginalVal == Opposant, % Si la case initiale est un opposant, on a donc une case libre potentiellement jouable
		Increment is Index-NewIndex, % Note : on peut supprimer NewIndex ou Increment. Il faut la soustraction dans ce sens pour obtenir le (   -Increment)
		subBoard(Board,Index,Increment, L1), % On crée une sublist depuis la case du cran de droite, pour aller au bord /sublist(NewIndex, Bord, L1)
    % ATTENTION L'INCREMENT DOIT ETRE INVERSE ! - INCREMENT Si on veut jouer à droite, on cherche la sous liste de gauche, donc on évolue à gauche.
    % Note : Si on met l'NEWINDEX : on appelle subBoardRecursif (on met pas la case vide, dans la sublist)
    % Note : SI on met l'INDEX : on appelle subBoard (on met la case ennemeni dans la sublist)
    subListJusqueVide(L1,L2), % On récupère la sous liste de la case "à droite" jusqu'à la première case "vide"
    member(Player,L2),!. % On vérifie si dans cette zone on a une case "à nous" (au player)

%%% Fonction pour savoir si une case est au bord. (Sup, inf ou côtés)
%%% True si sur la première ou dernière ligne, ou première ou dernière colonne
% Indice : l'index de la case où on veut savoir si elle est au bord, Increment : la direction dans laquelle on regarde si elle est au bord.
% Une case sur la colonne de gauche mais en regardant vers la droite ne sera pas "au bord".
% La fonction raisonne en "Est-ce que si tu vas un coup plus loin (Increment) depuis ta case (Indice), tu sors du tableau ?"
	estAuBord(Indice,Increment) :- compare(=,Increment,-1),coordValtoXY(X,_,Indice), X == 0,!.
	estAuBord(Indice,Increment) :- compare(=,Increment,1),coordValtoXY(X,_,Indice), X == 7,!.
	% Vérification si on va vers le bord haut : Notre incrément est soit -7, -8 ou -9 donc <-6
	estAuBord(Indice,Increment) :- compare(<,Increment,-6), coordValtoXY(_,Y,Indice), Y == 0,!.
	% Vérification si on va vers le bord haut : Notre incrément est soit +7, +8 ou +9 donc > 6
	estAuBord(Indice,Increment) :- compare(>,Increment,6),coordValtoXY(_,Y,Indice), Y == 7,!.
% Cas particulier des bords droits et gauches
	estAuBord(Indice,Increment) :- compare(=,Increment,-7),coordValtoXY(X,_,Indice), X == 7,!.
	estAuBord(Indice,Increment) :- compare(=,Increment,+9),coordValtoXY(X,_,Indice), X == 7,!.
	estAuBord(Indice,Increment) :- compare(=,Increment,-9),coordValtoXY(X,_,Indice), X == 0,!.
	estAuBord(Indice,Increment) :- compare(=,Increment,+7),coordValtoXY(X,_,Indice), X == 0,!.

%%% But : récupérer la liste de valeur, depuis "Index", dans la direction de "Incrément", jusqu'au bord le plus proche. En diagonale, en latérial ou en vertical
%%% Sortie : Dans Subboard, les valeurs dans l'ordre de Index (EXCLU!) au bord du tableau, en faisant des sauts de "Increment"
% Board : le plateau de jeu, Index : L'indice de la case de départ qui servira à créer la liste extraite du plateau de jeu,
% Increment : la direction dans laquelle sera construite la liste, par rapport à la case de départ, Liste : la liste de sortie,
% qui sera constitué de tous les éléments entre la case (non incluse) de départ, et le premier bord rencontré (sortie)
	subBoardRecursif(_,Index,Increment,[]) :-
    estAuBord(Index,Increment),!. % Condition d'arrêt : la case courante est sur le bord de la grille de jeu.
% Note : La notion de "bord" dépend de la direction dans laquelle on va (donc selon l'incrément ! ^_^ )

	subBoardRecursif(Board,Index,Increment,SubBoard) :- % La case courante n'est pas au bord (sinon on se serait arrêté)
		NewIndex is Index+Increment, % Incrément de la valeur
		nth0(NewIndex, Board, Val), % Récupère la valeur dans la case de N°"Index+1" du plateau de jeu
		append([Val],NewSubBoard,SubBoard), % Ajout de cet élément à la SubBoard
		subBoardRecursif(Board,NewIndex,Increment,NewSubBoard). % Récursion pour continue la création du Subboard.

%%% Bidouille pour pouvoir avoir la liste complète des valeurs à avoir (avec la valeur à INDEX, si on n'en veut pas, on peut simplifier le code et/ou
%%% appeler directement subBoardRecursif)
%%% Sortie : Dans Subboard, les valeurs dans l'ordre de Index (compris) au bord du tableau, en faisant des sauts de "Increment"
% Board : le plateau de jeu, Index : L'indice de la case de départ qui servira à créer la liste extraite du plateau de jeu,
% Increment : la direction dans laquelle sera construite la liste, par rapport à la case de départ,
% Liste : la liste de sortie, qui sera constitué de tous les éléments entre la case (INCLUSE) de départ, et le premier bord rencontré (sortie)
	subBoard(Board,Index,Increment,SubBoard) :-
		nth0(Index, Board, Val), % Récupère la valeur dans la case de N°"Index" du plateau de jeu
		append([Val],NewSubBoard,SubBoard), % Ajout de cet élément à la SubBoard (Ici, on ajoute le premier élément, celui à l'index INDEX)
		subBoardRecursif(Board,Index,Increment,NewSubBoard). % Lancement de la récursion

%%% subListJusqueVide : on coupe la liste donnée en paramètre jusqu'à la première case vide
% Liste1 : La liste qu'on veut réduire (IN), Liste2 : la liste réduite (L1) jusqu'à la rencontre avec une case vide (OUT)
	subListJusqueVide([],[]) :- !. % Condition d'arrêt si on tombe que sur des cases pleines
	subListJusqueVide([H|_], []) :- var(H), !. % Condition d'arrêt si on tombe sur une case vide
	% Récusrion tant qu'on tombe sur des cases pleines (instanciées = pas de variable)
	subListJusqueVide([H|ListeEntree], [H|ListeSortie]) :- nonvar(H),subListJusqueVide(ListeEntree, ListeSortie). 

%%% subListJusqueVal : on coupe la liste donnée en paramètre jusqu'à la première case vide ou case définie par "Player"
% Liste1 : La liste qu'on veut réduire (IN), Val : un valeur, qui si on tombe dessus dans la liste, arrête la création de la liste de sortie,
% Liste2 : la liste réduite (L1) jusqu'à la rencontre avec une case vide (OUT)
	subListJusqueValINCLUS([],_,[]) :- !. % Condition d'arrêt si on tombe que sur des cases pleines
	subListJusqueValINCLUS([H|_], _, []) :- var(H), !. % Condition d'arrêt si on tombe sur une case vide
	subListJusqueValINCLUS([H|_], Val, [H]) :- H==Val, !. % Condition d'arrêt si on tombe sur une case vide
	% Récusrion tant qu'on tombe sur des cases pleines (instanciées = pas de variable)
	subListJusqueValINCLUS([H|ListeEntree], Val, [H|ListeSortie]) :- nonvar(H),subListJusqueValINCLUS(ListeEntree,Val, ListeSortie). 

%%%%%%%%%%%%%%%%%%%% Clauses de jeu %%%%%%%%%%%%%%%%%%%%
%%% Play a Move, the new Board will be the same, but one value will be instanciated with the Move
%%% PRÉCONDITION : Move est un indice licite où le joueur peut jouer.
% Move est l'index (commence à 0) du pion joué
	playMove(Board,-1,Board,_).
	playMove(Board,Move,NewBoard,Player) :-
		nth0(Move,Board,Player), % on place le pion joué à sa place (Move)
		playMoveRight(Move, Player, Board, NewBoardR), % Direction droite on regarde (et remplace s'il faut)
		playMoveDownRight(Move, Player, NewBoardR, NewBoardDR), % Direction droite on regarde (et remplace s'il faut)
		playMoveDown(Move, Player, NewBoardDR, NewBoardD), % Direction droite on regarde (et remplace s'il faut)
		playMoveDownLeft(Move, Player, NewBoardD, NewBoardDL), % Direction droite on regarde (et remplace s'il faut)
		playMoveLeft(Move, Player, NewBoardDL, NewBoardL), % Direction droite on regarde (et remplace s'il faut)
		playMoveUpLeft(Move, Player, NewBoardL, NewBoardUL), % Direction droite on regarde (et remplace s'il faut)
		playMoveUp(Move, Player, NewBoardUL, NewBoardU), % Direction droite on regarde (et remplace s'il faut)
		playMoveUpRight(Move, Player, NewBoardU, NewBoard), % Direction droite on regarde (et remplace s'il faut)
		!. %
		%playMoveUpRight(Move, Player, Board, NewBoard). %

%%% RIGHT %%%
	% le pion est sur les deux colonnes les plus à droite -> pas possible de marquer vers la droite
	playMoveRight(Move, _, Board, Board) :- coordValtoXY(X,_,Move), X > 6, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveRight(Move, Player, Board, Board) :- Neighbour is Move+1, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveRight(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, 1, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move + 1,
		searchNReplace(NextMove, 1, SubBoard, Player, Board, NewBoard), % effectue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveRight(_, _, Board, Board). 

%%% DOWNRIGHT %%%
% On ne peut pas jouer au dessus
	% le pion est sur les deux colonnes les plus à droite ou en bas -> pas possible de marquer
	playMoveDownRight(Move, _, Board, Board) :- coordValtoXY(X,Y,Move), X > 6, Y >6, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveDownRight(Move, Player, Board, Board) :- Neighbour is Move+9, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveDownRight(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, 9, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move + 9,
		searchNReplace(NextMove, 9, SubBoard, Player, Board, NewBoard), % effetue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveDownRight(_, _, Board, Board).

%%% DOWN %%%
	% le pion est sur les deux lignes les plus en bas -> pas possible de marquer
	playMoveDown(Move, _, Board, Board) :- coordValtoXY(_,Y,Move), Y > 6, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveDown(Move, Player, Board, Board) :- Neighbour is Move+8, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveDown(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, 8, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move + 8,
		searchNReplace(NextMove, 8, SubBoard, Player, Board, NewBoard), % effetue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveDown(_, _, Board, Board).

%%% DOWNLEFT %%%
	% le pion est sur les deux lignes les plus en bas -> pas possible de marquer
	playMoveDownLeft(Move, _, Board, Board) :- coordValtoXY(X,Y,Move), X < 2, Y > 6, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveDownLeft(Move, Player, Board, Board) :- Neighbour is Move+7, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveDownLeft(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, 7, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move + 7,
		searchNReplace(NextMove, 7, SubBoard, Player, Board, NewBoard), % effetue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveDownLeft(_, _, Board, Board).

%%% LEFT %%%
	% le pion est sur les deux lignes les plus en bas -> pas possible de marquer
	playMoveLeft(Move, _, Board, Board) :- coordValtoXY(X,_,Move), X < 2, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveLeft(Move, Player, Board, Board) :- Neighbour is Move-1, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveLeft(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, -1, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move + -1,
		searchNReplace(NextMove, -1, SubBoard, Player, Board, NewBoard), % effetue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveLeft(_, _, Board, Board).

%%% UPLEFT %%%
	% le pion est sur les deux lignes les plus en bas -> pas possible de marquer
	playMoveUpLeft(Move, _, Board, Board) :- coordValtoXY(X,Y,Move), X < 2, Y < 2, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveUpLeft(Move, Player, Board, Board) :- Neighbour is Move-9, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveUpLeft(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, -9, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move -9,
		searchNReplace(NextMove, -9, SubBoard, Player, Board, NewBoard), % effetue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveUpLeft(_, _, Board, Board).

%%% UP %%%
	% le pion est sur les deux lignes les plus en bas -> pas possible de marquer
	playMoveUp(Move, _, Board, Board) :- coordValtoXY(_,Y,Move), Y < 2, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveUp(Move, Player, Board, Board) :- Neighbour is Move-8, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveUp(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, -8, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move -8,
		searchNReplace(NextMove, -8, SubBoard, Player, Board, NewBoard), % effetue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveUp(_, _, Board, Board).

%%% UPRIGHT %%%
	% le pion est sur les deux lignes les plus en bas -> pas possible de marquer
	playMoveUpRight(Move, _, Board, Board) :- coordValtoXY(X,Y,Move), X > 6, Y < 2, !.
	% le voisin de droite est un ami OU une variable -> idem
	playMoveUpRight(Move, Player, Board, Board) :- Neighbour is Move-7, nth0(Neighbour, Board, Pion),(var(Pion);Pion==Player), !.
	% recherche en profondeur et remplacement car on vient d'éliminer les cas évidents où on ne marque pas
	playMoveUpRight(Move, Player, Board, NewBoard) :-
		subBoardRecursif(Board, Move, -7, SubBoard), % récupère la liste des cases dans cette direction
		NextMove is Move -7,
		searchNReplace(NextMove, -7, SubBoard, Player, Board, NewBoard), % effetue le remplacement si il y a des points à marquer
		!.
	% règle toujours vraie, il faut encore regarder dans d'autres directions !
	playMoveUpRight(_, _, Board, Board).

	replace([_|T], 0, X, [X|T]) :- !.
	replace([H|T], I, X, [H|R]):- I > -1, NI is I-1, replace(T, NI, X, R), !.
	replace(L, _, _, L).

	searchNReplace(_, _, [H|_], Player, Board, Board) :- nonvar(H), H==Player, !. % le pion est initialisé ET ami -> on marque des points !
	searchNReplace(Index, Pas, [H|T], Player, Board, FinalBoard) :-
		nonvar(H), H\==Player, % Si le voisin est une case ennemie initialisée
		NewIndex is Index + Pas, % on avance
		searchNReplace(NewIndex, Pas, T, Player, Board, NewBoard), % On effectue la même recherche sur le voisin suivant -> descente en profondeur de l'arbre.
		replace(NewBoard, Index, Player, FinalBoard), %  Ne s'exécute que si searchNReplace est vraie == on a rencontré un pion ami directement après une liste d'ennemis
		% remplace le pion à l'index Index par un pion Player dans le board que nous a remonté l'appel précédent de SNR. Crée un nouveau board que l'on renvoie à l'appelant.
		!.
% On fait en sorte d'unifier les deux plateaux, et on utilise nth0 comme un setteur à un emplacement donné.

%%% Remove old board/save new on in the knowledge base
	applyIt(Board,NewBoard) :- retract(board(Board)), assert(board(NewBoard)).
% Retract pour supprimer de la base de connaissance le fait du plateau courant, et assert permet de rajouter le nouveau plateau en mémoire.

%%% Predicate to get the next player
	changePlayer('x','o').
	changePlayer('o','x').
% Inversion des joueurs

%%%%%%%%%%%%%%%%%%%% Clauses PRINCIPALES du jeu %%%%%%%%%%%%%%%%%%%%
	play(_, _, _, _, _) :- gameover(Winner), !, write('Game is Over. Winner : '), writeln(Winner), displayBoard, !.

	play(Player, IAPlayer1, IAPlayer2, ParameterIA1, ParameterIA2) :-
		displayBoard, % print it % Affichage du plateau
		write('New turn for : '), writeln(Player), % Pour écrire le tour du joueur
		board(Board), % instanciate the board from the knowledge base  % Récupère le board dans les faits du prog.
		launchIA(IAPlayer1, Board, Player, Move, ParameterIA1),
		playMove(Board,Move,NewBoard,Player), % Play the move and get the result in a new Board % Fait le mouvement, unification sur l'ancien plateau
		applyIt(Board, NewBoard), % Remove the old board from the KB and store the new one % Suppressionde l'ancien plateau de la mémoire, garde le nouveau
	    changePlayer(Player,NextPlayer), % Change the player before next turn %
        play(NextPlayer, IAPlayer2, IAPlayer1, ParameterIA2, ParameterIA1). % next turn!
	
	% Possibilités pour les joueurs :
	%	- human
	%	- random
	%	- greedy
	%	- greedyDepth2
	%	- greedyValued
	%	- heuristicOneLevel
	%	- heuristicNlevels
	%	- mc
	%	- mcts  
	launchIA(human, Board, Player, Move, _) :-
		read_entry(Board, Player, Move).
	launchIA(random,Board, Player, Move, _) :-
		ia(Board, Move, Player).
	launchIA(greedy, Board, Player, Move, _) :-
		iaGreedyMax(Board, Move, Player).
	launchIA(greedyDepth2, Board, Player, Move, _) :-
		iaGreedyMaxDepth(Board, Move, Player).
	launchIA(greedyValued, Board, Player, Move, _) :-
		iaGreedyValuedMax(Board, Move, Player).
	launchIA(heuristicOneLevel, Board, Player, Move, _) :-
		iaHeuristicOneLevel(Board, Move, Player).
	launchIA(heuristicNlevels, Board, Player, Move, Parameter) :-
		iaHeuristicNlevels(Board, Move, Player, Parameter).
	launchIA(mc, Board, Player, Move, _) :-
		iaMonteCarlo(Board, Move, Player).
	launchIA(mcts, Board, Player, Move, Parameter) :-
		iaMCTS(Board, Move, Player, Parameter).
	launchIA(_, Board, Player, Move, _) :-
		ia(Board, Move, Player).
		
		
%%%%%%%%%%%%%%%%%%%% Clauses de gestion d'utilisateur réel %%%%%%%%%%%%%%%%%%%%
% Board : le plateau de jeu, Player : le joueur, X : la valeur retournée par la clause (entrée de l'utilisateur, sortie)
	read_entry(Board,Player,X) :-
		casesJouables(Board, 0, Player, Liste), %On récupère les entrées possibles de l'utilisateur
		write('Playable index : '),
		nl, %New Line
		printListe(Liste), %Affichage de la liste jouable
		nl, %New Line
		write('Please type number of the case you want to play [0-63]'),
		repeat,
		nl, %New Line
		read(X),
		integer(X), %Si c'est bien un entier
		member(X,Liste).

%%% Permet de printer la liste passée en paramètre, avec des espaces
% Liste : la liste à printer à l'écran
	printListe([]).
	printListe([H|Liste]) :- write(H), write(' '),printListe(Liste).


%%%%%%%%%%%%%%%%%%%% Clauses d'affichage %%%%%%%%%%%%%%%%%%%%
%%% Print the value of the board at index N:
% if its a variable, print ? and x or o otherwise.
	printVal(N) :- board(B), nth0(N,B,Val), var(Val), write('?'), !.
% Récupère plateau en mémoire, Vrai si val est la valeur de la liste B de la Nième position, si c'est une variable (non unifiée), on print, on coupe pour le pas afficher en double.
	printVal(N) :- board(B), nth0(N,B,Val), write(Val).

%%% Display the board
	displayBoard:-
		writeln('*----------*'),
		printVal(0),printVal(1),printVal(2),printVal(3),printVal(4),printVal(5),printVal(6),printVal(7),writeln(''),
		printVal(8),printVal(9),printVal(10),printVal(11),printVal(12),printVal(13),printVal(14),printVal(15),writeln(''),
		printVal(16),printVal(17),printVal(18),printVal(19),printVal(20),printVal(21),printVal(22),printVal(23),writeln(''),
		printVal(24),printVal(25),printVal(26),printVal(27),printVal(28),printVal(29),printVal(30),printVal(31),writeln(''),
		printVal(32),printVal(33),printVal(34),printVal(35),printVal(36),printVal(37),printVal(38),printVal(39),writeln(''),
		printVal(40),printVal(41),printVal(42),printVal(43),printVal(44),printVal(45),printVal(46),printVal(47),writeln(''),
		printVal(48),printVal(49),printVal(50),printVal(51),printVal(52),printVal(53),printVal(54),printVal(55),writeln(''),
		printVal(56),printVal(57),printVal(58),printVal(59),printVal(60),printVal(61),printVal(62),printVal(63),writeln(''),
		writeln('*----------*').

	
%%%%%%%%%%%%%%%%%%%% Clauses utile pour le placement de valeurs %%%%%%%%%%%%%%%%%%%%
%%% Place les quatre pions de départ (deux pour chaque joueur) au centre du plateau de jeu
% Board36 : nouveau plateau avec les quatre pions placés
	placeFourFirstPoints(Board36) :- board(Board),
		placePoint(Board, 27, 'x', Board27),
		placePoint(Board27, 28, 'o', Board28),
		placePoint(Board28, 35, 'o', Board35),
		placePoint(Board35, 36, 'x', Board36).

%%% Positionne une valeur sur le board à un index sur le board et renvoie le nouveau board
% Board : plateau en entrée, Index : index de la valeur à placer ([0,63]), Value : valeur à placer, NewBoard : board obtenu en sortie
	placePoint(Board, Index, Value, NewBoard) :- nth0(Index, Board, Value), Board=NewBoard.

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%% Start the game! %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialisation du board (de taille 64), assert = mettre dans la base de connaissance, X commence la partie
	% Possibilités pour les joueurs :
	%	- human
	%	- random
	%	- greedy
	%	- greedyDepth2
	%	- greedyValued
	%	- heuristicOneLevel
	%	- heuristicNlevels
	%	- mc
	%	- mcts

	init(Player, IAPlayer1, IAPlayer2, ParameterIA1, ParameterIA2):-
		length(Board,64), assert(board(Board)), placeFourFirstPoints(NewBoard), applyIt(Board, NewBoard), play(Player, IAPlayer1, IAPlayer2, ParameterIA1, ParameterIA2),
		retractall(board(_)), retractall(boardMC(_)), retractall(lJoues(_)), retractall(lGagnes(_)).
		
% Nécessaire pour les tests automatiques
init1  :- init('x',  random ,  random ,_, _).
init2  :- init('x',  random ,  greedy ,_, _).
init3  :- init('x',  random ,  greedyDepth2 ,_, _).
init4  :- init('x',  random ,  greedyValued ,_, _).
init5  :- init('x',  random ,  heuristicOneLevel ,_, _).
init6  :- init('x',  random ,  heuristicNlevels ,_, _).
init7  :- init('x',  greedy ,  random ,_, _).
init8  :- init('x',  greedy ,  greedy ,_, _).
init9  :- init('x',  greedy ,  greedyDepth2 ,_, _).
init10  :- init('x',  greedy ,  greedyValued ,_, _).
init11  :- init('x',  greedy ,  heuristicOneLevel ,_, _).
init12  :- init('x',  greedy ,  heuristicNlevels ,_, _).
init13  :- init('x',  greedyDepth2 ,  random ,_, _).
init14  :- init('x',  greedyDepth2 ,  greedy ,_, _).
init15  :- init('x',  greedyDepth2 ,  greedyDepth2 ,_, _).
init16  :- init('x',  greedyDepth2 ,  greedyValued ,_, _).
init17  :- init('x',  greedyDepth2 ,  heuristicOneLevel ,_, _).
init18  :- init('x',  greedyDepth2 ,  heuristicNlevels ,_, _).
init19  :- init('x',  greedyValued ,  random ,_, _).
init20  :- init('x',  greedyValued ,  greedy ,_, _).
init21  :- init('x',  greedyValued ,  greedyDepth2 ,_, _).
init22  :- init('x',  greedyValued ,  greedyValued ,_, _).
init23  :- init('x',  greedyValued ,  heuristicOneLevel ,_, _).
init24  :- init('x',  greedyValued ,  heuristicNlevels ,_, _).
init25  :- init('x',  heuristicOneLevel ,  random ,_, _).
init26  :- init('x',  heuristicOneLevel ,  greedy ,_, _).
init27  :- init('x',  heuristicOneLevel ,  greedyDepth2 ,_, _).
init28  :- init('x',  heuristicOneLevel ,  greedyValued ,_, _).
init29  :- init('x',  heuristicOneLevel ,  heuristicOneLevel ,_, _).
init30  :- init('x',  heuristicOneLevel ,  heuristicNlevels ,_, _).
init31  :- init('x',  heuristicNlevels ,  random ,_, _).
init32  :- init('x',  heuristicNlevels ,  greedy ,_, _).
init33  :- init('x',  heuristicNlevels ,  greedyDepth2 ,_, _).
init34  :- init('x',  heuristicNlevels ,  greedyValued ,_, _).
init35  :- init('x',  heuristicNlevels ,  heuristicOneLevel ,_, _).
init36  :- init('x',  heuristicNlevels ,  heuristicNlevels ,_, _).


		