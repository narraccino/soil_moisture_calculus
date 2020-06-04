function [lat, lon, stazione] = calcCoord(file_coord_excel, stationCode)
%Funzione per l'estrazione delle coordinate di una stazione da file excel.
%Permette di estrarre da un file excel opportunamente realizzato latitudine
%e longitudine di una stazione passandogli in input il codice identificativo.
%
% file_coord_excel: nome del file excel nel quale sono presenti le informazioni sulle stazioni
% stationCode: codice identificativo della stazione di cui si vogliono le coordinate

    %lettura del file excel
    T = readtable(file_coord_excel);

    %stampa a schermo di tutti i codici e i comuni delle stazioni presenti
    [T.COD, T.COMUNE]

    %definizione della stringa contenente il codice della stazione desiderata
    stazione = string(stationCode);

    %selezione della riga del file excel contenente le informazioni della
    %stazione desiderata
    [row, ~] = find(T.COD == stazione);
    
    %selezione di latitudine e longitudine dalla riga contenente le
    %informazioni della stazione desiderata
    lat = str2double(cell2mat(table2array(T(row,5))));
    lon = str2double(cell2mat(table2array(T(row,6))));
    
end