:- begin_tests(reversomerged).
:- use_module(reversomerged).

%! nbOfPoints
test(nbOfPoints, all(Nb == [23])) :-
nbOfPoints(
['o', _ ,'o','o','o','o','o','o',
 'x','o','o','o','o','o','o','o',
 'o','o','x','o','o','o','o','o',
 'x','x','x','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'o','x','o',
 'x','o','o','x','x','x','x','x',
 'x','o','x','x', _ , _ , _ ,'x',
 'o','x','x','x','x','x','x','o'],'x',Nb).

test(nbOfPoints, all(Nb == [34])) :-
nbOfPoints(
['o', _ ,'o','o','o','o','o','o',
 'x','o','o','o','o','o','o','o',
 'o','o','x','o','o','o','o','o',
 'x','x','x','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'o','x','o',
 'x','o','o','x','x','x','x','x',
 'x','o','x','x', _ , _ , _ ,'x',
 'o','x','x','x','x','x','x','o'],'o',Nb).

test(isBoardFull) :-
not(isBoardFull(
['o', _ ,'o','o','o','o','o','o',
 'x','o','o','o','o','o','o','o',
 'o','o','x','o','o','o','o','o',
 'x','x','x','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'o','x','o',
 'x','o','o','x','x','x','x','x',
 'x','o','x','x', _ , _ , _ ,'x',
 'o','x','x','x','x','x','x','o'])).

%! isBoardFull
test(isBoardFull) :-
not(isBoardFull(
['o', _ ,'o','o','o','o','o','o',
 'x','o','o','o','o','o','o','o',
 'o','o','x','o','o','o','o','o',
 'x','x','x','o','o','o','o','o',
 'x','x','o','o','o','o','x','o',
 'x','o','o','x','x','x','x','x',
 'x','o','x','x','o','o','x','x',
 'o','x','x','x','x','x','x','o'])).
test(isBoardFull) :-
isBoardFull(
['o','o','o','o','o','o','o','o',
 'x','o','o','o','o','o','o','o',
 'o','o','x','o','o','o','o','o',
 'x','x','x','o','o','o','o','o',
 'x','x','o','o','o','o','x','o',
 'x','o','o','x','x','x','x','x',
 'x','o','x','x','o','o','x','x',
 'o','x','x','x','x','x','x','o']).

test(isBoardFull) :-
isBoardFull(
['o', _ ,'x','x','x','x','x','x',
 'o','o','x','x','x','x','x','x',
 'o','o','o','x','x','x','x','x',
 'o','o','x','o','x','x','x','x',
 'o','o','o','x','o','x','x','x',
 'o','o','x','o','x','o','x','x',
 'o','o','x','x','o','x','o','x',
 'o','o','o','o','o','o','o','o']).

test(isBoardFull) :-
not(isBoardFull([
'x','o','o','o','o','o','o','o',
 _ ,'x','o','x','x','o','o','x',
'x','x','x','o','x','x','o','x',
 _ , _ ,'x','o','o','x','o','x',
'x','x','x','x','x','o','x','x',
 _ ,'x','x','x','x','x','x','x',
 _ , _ ,'x','x','x','x','x', _ ,
 _ , _ , _ ,'o', _ ,'x', _ , _ ])).

%!  winner
test(winner, all(Winner == [x])) :-
winner(
['o', _ ,'x','x','x','x','x','x',
 'o','o','x','x','x','x','x','x',
 'o','o','o','x','x','x','x','x',
 'o','o','x','o','x','x','x','x',
 'o','o','o','x','o','x','x','x',
 'o','o','x','o','x','o','x','x',
 'o','o','x','x','o','x','o','x',
 'o','o','o','o','o','o','o','o'], Winner).

test(winner, all(Winner == [o])) :-
winner(
['o', _ ,'x','x','x','x','x','x',
 'o','o','x','x','x','o','x','x',
 'o','o','o','x','x','o','x','o',
 'o','o','o','o','x','o','o','x',
 'o','o','o','x','o','o','o','o',
 'o','o','x','o','o','o','x','x',
 'o','o','x','x','o','x','o','x',
 'o','o','o','o','o','o','o','o'], Winner).

test(winner, all(Winner == ['Egalite'])) :-
winner(
['o','x','x','x','x','x','x','x',
 'o','o','x','x','x','x','x','x',
 'o','o','x','x','x','x','x','x',
 'o','o','x','x','x','o','o','x',
 'o','o','x','x','o','o','o','x',
 'o','o','x','o','o','o','x','x',
 'o','o','o','x','x','x','o','o',
 'o','o','o','o','o','o','o','o'], Winner).


%!  coordXYtoVal
% corners
test(coordXYtoVal, all(Val == [0])) :- % top-left
coordXYtoVal(0,0,Val).

test(coordXYtoVal, all(Val == [63])) :- % bottom-right
coordXYtoVal(7,7,Val).

test(coordXYtoVal, all(Val == [56])) :- % top-right
coordXYtoVal(0,7,Val).

test(coordXYtoVal, all(Val == [7])) :- % bottom-left
coordXYtoVal(7,0,Val).

% edges
test(coordXYtoVal, all(Val == [3])) :- % top
coordXYtoVal(3,0,Val).

test(coordXYtoVal, all(Val == [61])) :- % bottom
coordXYtoVal(5,7,Val).

test(coordXYtoVal, all(Val == [32])) :- % left
coordXYtoVal(0,4,Val).

test(coordXYtoVal, all(Val == [23])) :- % right
coordXYtoVal(7,2,Val).

% ordinary
test(coordXYtoVal, all(Val == [37])) :-
coordXYtoVal(5,4,Val).

test(coordXYtoVal, all(Val == [25])) :-
coordXYtoVal(1,3,Val).


%!  coordValtoXY
% corners
test(coordValtoXY, all(X == [0])) :- % top-left
coordValtoXY(X,_,0).
test(coordValtoXY, all(Y == [0])) :-
coordValtoXY(_,Y,0).

test(coordValtoXY, all(X == [7])) :- % bottom-right
coordValtoXY(X,_,63).
test(coordValtoXY, all(Y == [7])) :-
coordValtoXY(_,Y,63).

test(coordValtoXY, all(X == [0])) :- % top-right
coordValtoXY(X,_,56).
test(coordValtoXY, all(Y == [7])) :-
coordValtoXY(_,Y,56).

test(coordValtoXY, all(X == [7])) :- % bottom-left
coordValtoXY(X,_,7).
test(coordValtoXY, all(Y == [0])) :-
coordValtoXY(_,Y,7).

% edges
test(coordValtoXY, all(X == [3])) :- % top-left
coordValtoXY(X,_,3).
test(coordValtoXY, all(Y == [0])) :-
coordValtoXY(_,Y,3).

test(coordValtoXY, all(X == [5])) :- % bottom
coordValtoXY(X,_,61).
test(coordValtoXY, all(Y == [7])) :-
coordValtoXY(_,Y,61).

test(coordValtoXY, all(X == [0])) :- % left
coordValtoXY(X,_,32).
test(coordValtoXY, all(Y == [4])) :-
coordValtoXY(_,Y,32).

test(coordValtoXY, all(X == [7])) :- % right
coordValtoXY(X,_,23).
test(coordValtoXY, all(Y == [2])) :-
coordValtoXY(_,Y,23).

% ordinary
test(coordValtoXY, all(X == [5])) :-
coordValtoXY(X,_,37).
test(coordValtoXY, all(Y == [4])) :-
coordValtoXY(_,Y,37).

test(coordValtoXY, all(X == [1])) :-
coordValtoXY(X,_,25).
test(coordValtoXY, all(Y == [3])) :-
coordValtoXY(_,Y,25).


%!  iaGreedyMax
test(iaGreedyMax, all(ValeurCase == [53])) :-
iaGreedyMax(
['o', _ ,'o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o', _ , _ , _ ,'x',
 'o','o','x','x','o','x','x','x'], ValeurCase, 'x').

test(iaGreedyMax, all(ValeurCase == [36])) :-
iaGreedyMax(
['o', _ ,'o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o', _ , _ , _ ,'x',
 'o','o','x','x','o','x','x','x'], ValeurCase, 'o').


%!  maxListe
test(maxListe, all(ValueMax == [6])) :- % begining
maxListe([6,5,3,4,1,5], ValueMax, _).
test(maxListe, all(Indice == [0])) :-
maxListe([6,5,3,4,1,5], _, Indice).

test(maxListe, all(ValueMax == [8])) :- % end
maxListe([6,5,3,4,1,8], ValueMax, _).
test(maxListe, all(Indice == [5])) :-
maxListe([6,5,3,4,1,8], _, Indice).

test(maxListe, all(ValueMax == [9])) :- % ordinary
maxListe([6,5,3,9,1,8], ValueMax, _).
test(maxListe, all(Indice == [3])) :-
maxListe([6,5,3,9,1,8], _, Indice).

test(maxListe, all(ValueMax == [9,9,9])) :- % several occurences
maxListe([9,5,3,9,1,9], ValueMax, _).
test(maxListe, all(Indice == [0,3,5])) :-
maxListe([9,5,3,9,1,9], _, Indice).

test(maxListe, all(ValueMax == [9])) :- % with a negative number
maxListe([5,-1,3,9,1,7], ValueMax, _).
test(maxListe, all(Indice == [3])) :-
maxListe([5,-1,3,9,1,7], _, Indice).

test(maxListe, all(ValueMax == [-1])) :- % only negative numbers
maxListe([-6,-3,-4,-2,-1,-7], ValueMax, _).
test(maxListe, all(Indice == [4])) :-
maxListe([-6,-3,-4,-2,-1,-7], _, Indice).


%!  calculerGainUneDirection
test(calculerGainUneDirection, all(GainOUT == [2])) :-
calculerGainUneDirection(
['x', _ ,'o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o', _ , _ , _ ,'x',
 'o','o','x','x','o','x','x','x'], 36, -8, 'x', GainOUT).

test(calculerGainUneDirection, all(GainOut == [3])) :-
calculerGainUneDirection(
['x', _ ,'o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o', _ , _ , _ ,'x',
 'o','o','x','x','o','x','x','x'], 36, -9, 'x', GainOut).


%!  calculerGainUneCase
test(calculerGainUneCase, all(GainOut == [5])) :-
calculerGainUneCase(
['x', _ ,'o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o', _ , _ , _ ,'x',
 'o','o','x','x','o','x','x','x'], 36, 'x', GainOut).


%!  calculerGains
test(calculerGains, all(GainOut == [[3,1,5,1,5]])) :-
calculerGains(
['x', _ ,'o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o', _ , _ , _ ,'x',
 'o','o','x','x','o','x','x','x'], [1, 33, 36, 52, 53], GainOut, 'x').


%!  casesJouables
test(casesJouables, all(ListCoupsJouables == [[1, 33, 36, 52, 53]])) :-
casesJouables(
['x', _ ,'o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o', _ ,
 'x', _ ,'o','o', _ ,'x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o', _ , _ , _ ,'x',
 'o','o','x','x','o','x','x','x'], 0, 'x', ListCoupsJouables).

test(casesJouables, all(ListCoupsJouables == [[]])) :- % no move
casesJouables(
['x','o','o','o','o','x','o','o',
 'x','o','x','o','x','o','o','o',
 'o','o','o','x','o','o','o','o',
 'o','o','o','o','o','o','o','o',
 'x','o','o','o','o','x','o','x',
 'x','o','o','x','o','o','x','x',
 'x','o','x','o','o','o','x','x',
 'o','o','x','x','o','x','x','x'], 0, 'x', ListCoupsJouables).

test(casesJouables, all(ListCoupsJouables == [[8, 9, 24, 39, 46]])) :-
casesJouables(
[_ , _ , _ ,'x', _ ,'x', _ ,'x',
 _ , _ ,'x','x','x','x','o','o',
'o','o','o','o','o','o','o','o',
 _ ,'o','x','o','x','o','o','x',
'o','o','x','x','o','o','o', _ ,
'o','o','x','x','x','o', _ ,'o',
'x','x','x','x','x','x','x','o',
'x','x','x','x','x', _ ,'o','o'],0,'x', ListCoupsJouables).

test(casesJouables, all(ListCoupsJouables == [[5, 6, 9, 10, 12, 14, 17, 22, 25, 30, 32, 40, 41, 42, 46, 54]])) :- % very special case (diagonal opposite edge)
casesJouables(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ],0,'x', ListCoupsJouables).


%!  coup
test(coup) :- % jouable (bas)
coup(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 5, 'x').

test(coup) :- % jouable(diagonale)
coup(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 9,'x').

test(coup) :- % jouable(diagonale et gauche)
coup(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 46,'x').

test(coup) :- % non jouable (pas de voisins)
not(coup(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 24,'x')).

test(coup) :- % non jouable (pions voisins déjà au joueur)
not(coup(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 11,'x')).

test(coup) :- % non jouable (déjà un pion du joueur sur cette case)
not(coup(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 28,'x')).

test(coup) :- % non jouable (déjà un pion de l'adversaire sur cette case)
not(coup(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 37,'x')).


%!  licite
test(licite) :-
licite(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 5, 13, 'x').

test(licite) :-
licite(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 46, 37, 'x').

test(licite) :-
not(licite(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 11, 19, 'x')).

test(licite) :-
not(licite(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 5, 4, 'x')).

test(licite) :-
not(licite(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ , _ , _ , _ ], 5, 12, 'x')).


%!  estAuBord
test(estAuBord) :-
estAuBord(0,-9).
test(estAuBord) :-
estAuBord(0,-8).
test(estAuBord) :-
estAuBord(0,-7).
test(estAuBord) :-
estAuBord(0,-1).
test(estAuBord) :-
not(estAuBord(0,9)).
test(estAuBord) :-
not(estAuBord(0,8)).
test(estAuBord) :-
estAuBord(0,7).
test(estAuBord) :-
not(estAuBord(0,1)).


%!  subBoardRecursif
test(subBoardRecursif, all(SubBoard == [[o, o, o, o, o, x, x]])) :- % full column (down)
subBoardRecursif(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ ,'x', _ , _ ], 5, 8, SubBoard).

test(subBoardRecursif, all(SubBoard == [[]])) :- % edge (top : no neighbour)
subBoardRecursif(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ ,'x', _ , _ ], 5, -8, SubBoard).

test(subBoardRecursif, all(SubBoard == [[a,x,x,o,b]])) :- % some neighbours, some empty cases (a and b here)
subBoardRecursif(
[_ , _ , _ , _ , _ , _ , _ , _ ,
 _ , _ , _ , _ , a ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 b , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ ,'x', _ , _ ], 5, 7, SubBoard).


%!  subBoard
test(subBoard, all(SubBoard == [[c, o, o, o, o, o, x, x]])) :- % full column (down)
subBoard(
[_ , _ , _ , _ , _ , c , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ ,'x', _ , _ ], 5, 8, SubBoard).

test(subBoard, all(SubBoard == [[c]])) :- % edge (top : no neighbour)
subBoard(
[_ , _ , _ , _ , _ , c , _ , _ ,
 _ , _ , _ , _ , _ ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 _ , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ ,'x', _ , _ ], 5, -8, SubBoard).

test(subBoard, all(SubBoard == [[c,a,x,x,o,b]])) :- % some neighbours, some empty cases (a and b here)
subBoard(
[_ , _ , _ , _ , _ , c , _ , _ ,
 _ , _ , _ , _ , a ,'o', _ , _ ,
 _ , _ ,'o','x','o','o', _ , _ ,
 _ , _ ,'x','x','x','o', _ ,'o',
 _ ,'o','o','x','o','o','o','o',
 b , _ , _ ,'x','x','o', _ ,'o',
 _ , _ , _ ,'x','x','x', _ , _ ,
 _ , _ , _ , _ , _ ,'x', _ , _ ], 5, 7, SubBoard).


%!  subListJusqueVide
test(subListJusqueVide, all(ListeSortie == [[o, o, o, o, o, x, x]])) :- % no empty case
subListJusqueVide([o, o, o, o, o, x, x], ListeSortie).

test(subListJusqueVide, all(ListeSortie == [[]])) :- % no case
subListJusqueVide([], ListeSortie).

test(subListJusqueVide, all(ListeSortie == [[]])) :- % first neighbour is empty
subListJusqueVide([_,x,x,o,_], ListeSortie).

test(subListJusqueVide, all(ListeSortie == [[o,x]])) :- % empty case in the middle
subListJusqueVide([o,x,_,x,o,_,x], ListeSortie).


%!  subListJusqueValINCLUS
test(subListJusqueValINCLUS, all(ListeSortie == [[o, o, o, o, o, x]])) :- % value in the middle
subListJusqueValINCLUS([o, o, o, o, o, x, x], 'x', ListeSortie).

test(subListJusqueValINCLUS, all(ListeSortie == [[]])) :- % no case
subListJusqueValINCLUS([], 'x', ListeSortie).

test(subListJusqueValINCLUS, all(ListeSortie == [[a,x,x,o]])) :- % with empty cases
subListJusqueValINCLUS([a,x,x,o,_], 'o', ListeSortie).

test(subListJusqueValINCLUS, all(ListeSortie == [[o]])) :- % first value
subListJusqueValINCLUS([o,x,_,x,o,_,x], 'o', ListeSortie).

test(subListJusqueValINCLUS, all(ListeSortie == [[o,x]])) :- % empty case in the middle
subListJusqueValINCLUS([o,x,_,x,o,_,x], 'x', ListeSortie).

test(subListJusqueValINCLUS, all(ListeSortie == [[o]])) :- % no occurence
subListJusqueValINCLUS([o,o,a,o,o,b,o], 'o', ListeSortie).


%!  playMove
%!  playMoveRight
test(playMoveRight, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'o', ? , ? ,
  ? , ? ,'o','x','o','o', ? , ? ,
  ? , ? ,'x','x','x','o', ? ,'o',
  ? ,'o','o','x','o','o','o','o',
  ? , ? , ? ,'x','x','o', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveRight(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.

%!  playMoveRight
test(playMoveRight, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'o', ? , ? ,
  ? , ? ,'o','x','o','o', ? , ? ,
  ? , ? ,'x','x','x','o', ? ,'o',
  ? ,'o','o','x','o','o','o','o',
  ? , ? , ? ,'x','x','o', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveRight(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.

 %!  playMoveDown
test(playMoveDown, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ,
  ? , ? ,'o','x','o','x', ? , ? ,
  ? , ? ,'x','x','x','x', ? ,'o',
  ? ,'o','o','x','o','x','o','o',
  ? , ? , ? ,'x','x','x', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveDown(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.

%!  playMoveDownLeft
%%% Hard to test %%%
test(playMoveDownLeft, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'o', ? , ? ,
  ? , ? ,'o','x','o','o', ? , ? ,
  ? , ? ,'x','x','x','o', ? ,'o',
  ? ,'o','o','x','o','o','o','o',
  ? , ? , ? ,'x','x','o', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveDownLeft(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.

%!  playMoveLeft
test(playMoveLeft, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'o', ? , ? ,
  ? , ? ,'o','x','o','o', ? , ? ,
  ? , ? ,'x','x','x','o', ? ,'o',
  ? ,'o','o','x','o','o','o','o',
  ? , ? , ? ,'x','x','o', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveLeft(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.

 %!  playMoveUpLeft
test(playMoveUpLeft, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'o', ? , ? ,
  ? , ? ,'o','x','o','o', ? , ? ,
  ? , ? ,'x','x','x','o', ? ,'o',
  ? ,'o','o','x','o','o','o','o',
  ? , ? , ? ,'x','x','o', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveUpLeft(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.

%!  playMoveUp
test(playMoveUp, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'o', ? , ? ,
  ? , ? ,'o','x','o','o', ? , ? ,
  ? , ? ,'x','x','x','o', ? ,'o',
  ? ,'o','o','x','o','o','o','o',
  ? , ? , ? ,'x','x','o', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveUp(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.

%!  playMoveUpRight
test(playMoveUpLeft, all(NewBoard ==
[[? , ? , ? , ? , ? , ? , ? , ? ,
  ? , ? , ? , ? , ? ,'o', ? , ? ,
  ? , ? ,'o','x','o','o', ? , ? ,
  ? , ? ,'x','x','x','o', ? ,'o',
  ? ,'o','o','x','o','o','o','o',
  ? , ? , ? ,'x','x','o', ? ,'o',
  ? , ? , ? ,'x','x','x', ? , ? ,
  ? , ? , ? , ? , ? ,'x', ? , ? ]])) :-
playMoveUpRight(
 5, 'x',
[A , A , A , A , A , A , A , A ,
 A , A , A , A , A ,'o', A , A ,
 A , A ,'o','x','o','o', A , A ,
 A , A ,'x','x','x','o', A ,'o',
 A ,'o','o','x','o','o','o','o',
 A , A , A ,'x','x','o', A ,'o',
 A , A , A ,'x','x','x', A , A ,
 A , A , A , A , A ,'x', A , A ],
 NewBoard), A='?'.


%! iaGreedyValuedMax
test(iaGreedyValuedMax, all(CaseAJouer == [0])) :-
iaGreedyValuedMax([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],CaseAJouer,'x').

test(iaGreedyValuedMax, all(CaseAJouer == [21])) :-
iaGreedyValuedMax(['o','o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],CaseAJouer,'x').

%!calculerGainValued
test(calculerGainValued, all(ListeGains == [[52, 6, 2, 4, 0]])) :-
calculerGainValued([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    [0,21,29,38,56],ListeGains,'x').

%!calculerGainValuedUneCase
test(calculerGainValuedUneCase, all(Gain == [0])) :-
calculerGainValuedUneCase([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    9,'x',Gain).

test(calculerGainValuedUneCase, all(Gain == [52])) :-
calculerGainValuedUneCase([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    0,'x',Gain).

test(calculerGainValuedUneCase, all(Gain == [3])) :-
calculerGainValuedUneCase([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    37,'x',Gain).

test(calculerGainValuedUneCase, all(Gain == [4])) :-
calculerGainValuedUneCase([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    38,'x',Gain).

test(calculerGainValuedUneCase, all(Gain == [0])) :-
calculerGainValuedUneCase([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    62,'x',Gain).

%!calculerGainValuedPionsManges
test(calculerGainValuedPionsManges, all(Gain == [42])) :-
calculerGainValuedPionsManges([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    0,'x',Gain).

test(calculerGainValuedPionsManges, all(Gain == [0])) :-
calculerGainValuedPionsManges([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    9,'x',Gain).

test(calculerGainValuedPionsManges, all(Gain == [2])) :-
calculerGainValuedPionsManges([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o',_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    37,'x',Gain).

test(calculerGainValuedPionsManges, all(Gain == [2])) :-
calculerGainValuedPionsManges([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    38,'x',Gain).

test(calculerGainValuedPionsManges, all(Gain == [0])) :-
calculerGainValuedPionsManges([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    62,'x',Gain).


%!calculerGainValuedUneDirection
test(calculerGainValuedUneDirection, all(Gain == [28])) :-
calculerGainValuedUneDirection([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    0,1,'x',Gain).

test(calculerGainValuedUneDirection, all(Gain == [14])) :-
calculerGainValuedUneDirection([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    0,8,'x',Gain).

test(calculerGainValuedUneDirection, all(Gain == [0])) :-
calculerGainValuedUneDirection([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    0,-1,'x',Gain).

test(calculerGainValuedUneDirection, all(Gain == [0])) :-
calculerGainValuedUneDirection([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    0,9,'x',Gain).

test(calculerGainValuedUneDirection, all(Gain == [2])) :-
calculerGainValuedUneDirection([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    38,-1,'x',Gain).

test(calculerGainValuedUneDirection, all(Gain == [0])) :-
calculerGainValuedUneDirection([_,'o','o','o','o','o','o','x',
                   'o',_,_,_,_,_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'o',_,_,'x','o',_,_,_,
                   'x',_,_,'x','o','o',_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_,
                   _,_,_,_,_,_,_,_],
                   [10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     4, 2, 1, 1, 1, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],
                    59,-7,'x',Gain).

%!subValuedList
test(subValuedList, all(SubList == [[1,2,3,4]])) :-
subValuedList([1,2,3,4,5,6,7,8],4,SubList).

test(subValuedList, all(SubList == [[]])) :-
subValuedList([1,2,3,4,5,6,7,8],0,SubList).

test(subValuedList, all(SubList == [[]])) :-
subValuedList([],0,SubList).

test(subValuedList) :-
not(subValuedList([],3,_)).


%!valAbsBoard
test(valAbsBoard, all(NewBoard == [[10, 5, 5, 4, 4, 5, 5, 10, 5, 5, 3, 2, 2, 3, 5, 5, 5, 3, 4, 1, 1, 4, 3, 5, 4, 2, 4, 0, 0, 1, 2, 4, 4, 2, 4, 0, 0, 1, 2, 4, 5, 5, 4, 1, 1, 4, 3, 5, 5, 5, 3, 2, 2, 3, 5, 5, 10, 5, 5, 4, 4, 5, 5, 10]])) :-
valAbsBoard([10,-5, 5, 4, 4, 5,-5,10,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                     5, 3, 4, 1, 1, 4, 3, 5,
                     4, 2, 4, 0, 0, 1, 2, 4,
                     4, 2, 4, 0, 0, 1, 2, 4,
                     5, 5, 4, 1, 1, 4, 3, 5,
                    -5,-5, 3, 2, 2, 3,-5,-5,
                    10,-5, 5, 4, 4, 5,-5,10],NewBoard).

test(valAbsBoard, all(NewBoard == [[]])) :-
valAbsBoard([],NewBoard).

test(valAbsBoard, all(NewBoard == [[10, 5, 5, 4, 4, 5, 5, 10, 5, 5, 3, 2, 2, 3, 5, 5, 5, 3, 4, 1, 1, 4, 3, 5, 4, 2, 4, 0, 0, 1, 2, 4, 4, 2, 4, 0, 0, 1, 2, 4, 5, 5, 4, 1, 1, 4, 3, 5, 5, 5, 3, 2, 2, 3, 5, 5, 10, 5, 5, 4, 4, 5, 5, 10]])) :-
valAbsBoard([-10,-5, -5, -4, -4, -5,-5,-10,
                    -5,-5, -3, -2, -2, -3,-5,-5,
                     -5, -3, -4, -1, -1, -4, -3, -5,
                     -4, -2, -4, 0, 0, -1, -2, -4,
                     -4, -2, -4, 0, 0, -1, -2, -4,
                     -5, -5, -4, -1, -1, -4, -3, -5,
                    -5,-5, -3, -2, -2, -3,-5,-5,
                    -10,-5, -5, -4, -4, -5,-5,-10],NewBoard).



%!  replace
test(replace, all(ListeSortie == [[x, o, o, x, o, x, x]])) :- % middle
replace([x, o, o, o, o, x, x], 3, 'x', ListeSortie).

test(replace, all(ListeSortie == [[x, o, o, o, o, x, x]])) :- % beginning
replace([o, o, o, o, o, x, x], 0, 'x', ListeSortie).

test(replace, all(ListeSortie == [[x, o, o, o, o, x, x]])) :- % end
replace([x, o, o, o, o, x, o], 6, 'x', ListeSortie).

test(replace, all(ListeSortie == [[x, o, o, o, o, x, x]])) :- % index outside
replace([x, o, o, o, o, x, x], 9, 'x', ListeSortie).

test(replace, all(ListeSortie == [[x, o, o, o, o, x, x]])) :- % already OK
replace([x, o, o, o, o, x, x], 0, 'x', ListeSortie).


%!  searchNReplace
%%% Hard to test %%%


:- end_tests(reversomerged).
