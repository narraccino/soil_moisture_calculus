function array = scaleData(dataArray, ratio)
%Funzione per l'adeguamento della risoluzione spaziale di una matrice di dati.
%Dato un vettore di dati, li riarrangia in una matrice, effettua un
%ricampionamento di tali dati in base al ratio definito, estrae una matrice
%avente stesso numero di elementi del vettore di dati iniziale e ne
%restituisce la sua versione linearizzata.
%
% dataArray: vettore dei dati su cui applicare il ricampionamento
% ratio: rapporto Risoluzione Attuale / Risoluzione Desiderata

    %riarrangiamento del vettore dei dati in una matrice
    mis = sqrt(size(dataArray, 1));
    Wm = reshape(dataArray, [mis mis]);
    
    %ricampionamento dei dati in base al ratio
    Wm = kron(Wm, ones(ratio));
    
    %selezione della matrice centrata avente numero di elementi pari a
    %quello del vettore dei dati
    szcut = mis;
    i1 = (size(Wm, 1) - szcut)/2;
    ind1 = floor(i1+1:i1+szcut);
    Wm = Wm(ind1, ind1);
    
    %linearizzazione della matrice selezionata
    array = Wm(:);
    
end