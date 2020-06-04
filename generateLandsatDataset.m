function dataset = generateLandsatDataset(r, stations, dirImage, dirData, dirStazioni)
%Funzione che si occupa della generazione di un dataset contenente per
%ciascuna stazione desiderata le informazioni estrapolabili dalle immagini
%Landsat e i dati riguardanti le caratteristiche del suolo.
% 
% r: raggio della zona dell'immagine da prendere in considerazione
% stations: vettore contenente i numeri delle stazioni di cui si desidera calcolare i valori di SM
% dirImage: directory contenente le immagini telerilevate in formato tif, suddivise in cartelle rappresentanti ciascuna la data di acquisizione nel formato yyyy-mm-dd
% dirData: directory contenente i file in formato tif delle informazioni di capacità di campo e appassimento
% dirStazioni: directory contenente i file excel con i dati reali di SM rilevati da ciascuna stazione   

    h = waitbar(0, 'Please wait...');

    %stringhe contenenti i percorsi dei file tif con le informazioni su
    %appassimento e capacità di campo
    appFile = strcat(dirData, '\appassimento.tif');
    capFile = strcat(dirData, '\capCampo.tif');
    
    %struttura contenente i nomi delle cartelle con le immagini tif
    %telerilevate
    date = dir(strcat(dirImage, '\2*'));
    namesDate = {date.name};

    %inizializzazione della struttura per la memorizzazione dei dati
    dataset = struct('Stazione', {}, 'DatiSuolo', struct('CA', {}, 'CC', {}), 'DatiImmagini', struct('Data', {}, 'NDVI', {}, 'LSTB10', {}, 'LSTB11', {}, 'LSTMEAN', {}, 'RealSM', {}, 'monthlySM', {}), 'Raggio', {});
    
    %ciclo eseguito su tutte le stazioni selezionate al fine di creare un
    %elemento all'interno del dataset per ciascuna di esse
    for st = 1:size(stations,2)
        
        %calcolo delle coordinate per la stazione
        [lat, lon, stazione] = calcCoord('../Sat/CoordinateStazioni.xlsx', strcat('0PU', int2str(stations(st))));
        
        %gestione della barra di avanzamento
        step = (st-1)/(size(stations,2)+1);
        waitbar(step, h, sprintf('Analizing station 0PU%d', stations(st)));
        
        %inizializzazione dei campi Stazione e Raggio del dataset
        dataset(st).Stazione = stazione;
        dataset(st).Raggio = r;
        
        %estrazione valori di capacità di campo e appassimento
        [dataset(st).DatiSuolo.CC, dataset(st).DatiSuolo.CA] = calcCCCA(lat, lon, r, appFile, capFile);

        %ciclo eseguito su tutte le date d'acquisizione delle immagini
        for i = 1:length(namesDate)
            
            %lettura delle cartelle contenenti le immagini tif
            data = char(namesDate(i));
            B10 = dir(strcat(dirImage, '\', data, '\LC8[*](*)LST_B10.tif'));
            B11 = dir(strcat(dirImage, '\', data, '\LC8[*](*)LST_B11.tif'));
            NDVI = dir(strcat(dirImage, '\', data, '\LC8[*](*)NDVI.tif'));
            namesB10 = {B10.name};
            namesB11 = {B11.name};
            namesNDVI = {NDVI.name};

            %ciclo eseguito per ogni immagine all'interno della cartella
            %rappresentante ciascuna data delle immagini disponibili
            for j = 1:length(namesB10)
                
                dataset(st).DatiImmagini(i).Data = data;
                
                %vengono estratti i valori reali di soil moisture per la
                %data in esame
                [dataset(st).DatiImmagini(i).RealSM, dataset(st).DatiImmagini(i).monthlySM] = extractRealSM(dirStazioni, stazione, data);
                
                dataset(st).DatiImmagini(i).NDVI = nan;
                dataset(st).DatiImmagini(i).LSTB10 = nan;
                dataset(st).DatiImmagini(i).LSTB11 = nan;
                dataset(st).DatiImmagini(i).LSTMEAN = nan;
                try
                    %estrazione dei valori delle riflettanze per la
                    %stazione st-esima nella data i-esima
                    ndvi = loadDataFromImage(lat, lon, r, strcat(dirImage, '\', data, '\', char(namesNDVI(j))), "NDVI");
                    t1 = loadDataFromImage(lat, lon, r, strcat(dirImage, '\', data, '\', char(namesB10(j))), "T");
                    t2 = loadDataFromImage(lat, lon, r, strcat(dirImage, '\', data, '\', char(namesB11(j))), "T");
                    
                    %ricampionamento a 10 metri dei valori delle
                    %riflettanze ottenuti dalle immagini e memorizzazione
                    %di tali valori all'interno dei campi del dataset appositi 
                    dataset(st).DatiImmagini(i).NDVI = scaleData(cat(1, ndvi.NDVI), 3);
                    dataset(st).DatiImmagini(i).LSTB10 = scaleData(cat(1, t1.T), 3);
                    dataset(st).DatiImmagini(i).LSTB11 = scaleData(cat(1, t2.T), 3);
                    
                    %calcolo e memorizzazione della media tra le LST
                    %ottenute dalle bande 10 e 11 del Landsat-8
                    dataset(st).DatiImmagini(i).LSTMEAN = mean([dataset(st).DatiImmagini(i).LSTB10, dataset(st).DatiImmagini(i).LSTB11], 2);
                    
                    break;

                catch ME
                    %cattura di possibili eccezioni riscontrabili in fase
                    %di estrazione dei valori di riflettanza dall'immagine
                    %in esame e segnalazione del motivo a schermo
                    warning(getReport(ME));
                end
            end       
        end
    end
    
    waitbar(size(stations,2)/(size(stations,2)+1), h, 'Writing dataset on file');
    %salvataggio su file del dataset
    save(strcat(dirData, '\datasetLandsat.mat'), 'dataset');
    
    waitbar(1, h, 'Finished');
    close(h);
end