function generateTifFromData(filename, dataMatrix)
%Funzione per generare GeoTiff a partire da dati contenuti in una matrice.
%Utilizzata al fine di realizzare immagini GeoTiff contenenti i dati di
%appassimento e capacità di campo presenti in file .mat in forma matriciale
%
% filename: nome del file GeoTiff da generare
% dataMatrix: matrice contenente i dati

    %definizione della matrice di referenziazione
    cellLength = 100;
    refmat = makerefmat(474401.167439 + cellLength/2, 4375058.334001 + cellLength/2, cellLength, cellLength);
    
    %inizializzazione della matrice nella quale vengono riorganizzati i
    %dati prima di essere scritti su file
    rearrangedDataMatrix = [];
    
    %ciclo eseguito per ogni banda dell'immagine da realizzare
    for i=1:12  
        %selezione dei dati riguardante la i-esima banda
        month = flipud(squeeze(dataMatrix(i,:,:)));
        %aggiunta della banda nella matrice
        rearrangedDataMatrix = cat(3,rearrangedDataMatrix,month);
    end
    
    %trasformazione della matrice di referenziazione in oggetto
    %MapRasterReference
    R = refmatToMapRasterReference(refmat, size(rearrangedDataMatrix));

    %generazione del GeoTiff contenente i dati riarrangiati della matrice
    geotiffwrite(filename, rearrangedDataMatrix, R, 'CoordRefSysCode', 32633);
    
end