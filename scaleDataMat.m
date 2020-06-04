function array = scaleDataMat(dataMat, ratio)
%Funzione per l'adeguamento della risoluzione spaziale di una matrice di dati.
%Data una matrice di dati, effettua un ricampionamento di tali dati in base
%al ratio definito, estrae una matrice avente stesso numero di elementi della
%matrice di dati iniziale e ne restituisce la sua versione linearizzata.
%
% dataMat: matrice dei dati su cui applicare il ricampionamento
% ratio: rapporto Risoluzione Attuale / Risoluzione Desiderata

    %ricampionamento dei dati in base al ratio e selezione della matrice 
    %centrata avente numero di elementi pari a quello della matrice di dati
    szcut = size(dataMat, 1);
    dataMat = kron(dataMat, ones(ratio));
    i1 = (size(dataMat, 1) - szcut)/2;
    ind1 = floor(i1+1:i1+szcut);
    dataMat = dataMat(ind1, ind1);
    
    %linearizzazione della matrice selezionata
    array = dataMat(:);
    
end