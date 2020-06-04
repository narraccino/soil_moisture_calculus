function [Wh_max, Wp_min] = calcCCCA (lat, lon, r , appassimento, cap_campo)
%Funzione per il calcolo di capacità di campo e appassimento per una zona.
%La funzione si occupa dell'estrazione dei dati di capacità di campo e
%appassimento per un'area centrata nelle coordinate ottenute in ingresso e
%avente raggio definito.
%
% lat, lon: latitudine e longitudine del punto centrale della zona d'interesse
% radius: raggio in numero di pixel della ROI.
% appassimento: nome dell'immagine satellitare multibanda in formato GeoTiff con i dati di appassimento
% cap_campo: nome dell'immagine satellitare multibanda in formato GeoTiff con i dati di capacità di campo

    %estrazione dei dati di appassimento e capacità di campo dalle immagini
    %GeoTiff ricevute in input
    appass = loadDataFromImage(lat, lon, r, appassimento, ["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]);
    cap_campo = loadDataFromImage(lat, lon, r, cap_campo, ["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]);

    %selezione per ciascun pixel dell'area della capacità di campo massima
    %raggiunta nell'arco dell'anno
    CC = struct2array(cap_campo);
    Wh = max(CC(:,3:14)/1000, [], 2);
    
    %riarrangiamento dei valori di capacità di campo ottenuti in una matrice
    WhEdge = sqrt(size(Wh, 1));
    Wh = reshape(Wh, [WhEdge WhEdge]);

    %selezione per ciascun pixel dell'area dell'appassimento minimo
    %raggiunto nell'arco dell'anno
    CA = struct2array(appass);
    Wp = min(CA(:,3:14)/1000, [], 2);
    
    %riarrangiamento dei valori di appassimento ottenuti in una matrice
    WpEdge = sqrt(size(Wp, 1));
    Wp = reshape(Wp, [WpEdge WpEdge]);
    
    %sostituzione dei valori nulli tramite interpolazione
    Wh(Wh==0) = NaN;
    Wp(Wp==0) = NaN;
   
    Wh = inpaint_nans(Wh, 2);
    Wp = inpaint_nans(Wp, 2);
    
    %adeguamento della risoluzione dell'immagine da 100m a 10m
    Wh = scaleDataMat(Wh, 10);     %ratio 100/10
    Wp = scaleDataMat(Wp, 10);     %ratio 100/10

    %selezione della capacità di campo massima nella zona
    Wh_max = max(Wh);
    %selezione dell'appassimento minimo nella zona
    Wp_min = min(Wp);
    
end