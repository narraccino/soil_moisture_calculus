function [dataset] = generateSentinelDataset (r, stations, dirImage, dirData, dirStazioni)
%Funzione che si occupa della generazione di un dataset contenente per
%ciascuna stazione desiderata le informazioni estrapolabili dalle immagini
%Sentinel e i dati riguardanti le caratteristiche del suolo.
% 
% r: raggio della zona dell'immagine da prendere in considerazione
% stations: vettore contenente i numeri delle stazioni di cui si desidera calcolare i valori di SM
% dirImage: directory contenente le immagini telerilevate in formato tif, suddivise in cartelle rappresentanti ciascuna la data di acquisizione nel formato yyyy-mm-dd
% dirData: directory contenente i file in formato tif delle informazioni di capacità di campo e appassimento
% dirStazioni: directory contenente i file excel con i dati reali di SM rilevati da ciascuna stazione

    h = waitbar(0, 'Please wait...');

    %stringhe contenenti i percorsi dei file tif con le informazioni su
    %appassimento e capacità di campo
    appFilename = strcat(dirData, '\appassimento.tif');
    capFilename = strcat(dirData, '\capCampo.tif');

    %struttura contenente i nomi delle cartelle con le immagini tif
    %telerilevate
    date = dir(strcat(dirImage, '\2*'));
    namesDate = {date.name}; 

    %inizializzazione della struttura per la memorizzazione dei dati
    dataset = struct('Stazione', {}, 'DatiSuolo', struct('CA', {}, 'CC', {}), 'DatiImmagini', struct('Data', {}, 'B4', {}, 'B8', {}, 'RealSM', {}, 'monthlySM', {}), 'Raggio', {});
    
    %ciclo eseguito su tutte le stazioni selezionate al fine di creare un
    %elemento all'interno del dataset per ciascuna di esse
    for st = 1:size(stations,2)

        %calcolo delle coordinate per la stazione
        [lat, lon, stazione] = calcCoord(strcat(dirData, '\CoordinateStazioni.xlsx'), strcat('0PU', int2str(stations(st))));

        %gestione della barra di avanzamento
        step = (st-1)/(size(stations,2)+1);
        waitbar(step, h, sprintf('Analizing station 0PU%d', stations(st)));
        
        %inizializzazione dei campi Stazione e Raggio del dataset
        dataset(st).Stazione = stazione;
        dataset(st).Raggio = r;
        
        %estrazione valori di capacità di campo e appassimento
        [dataset(st).DatiSuolo.CC, dataset(st).DatiSuolo.CA] = calcCCCA(lat, lon, r, appFilename, capFilename);

        %ciclo eseguito su ogni data
        for i = 1:length(namesDate)

            %lettura delle cartelle contenenti le immagini tif
            data = char(namesDate(i));
            filesImage = strcat(dirImage, '\', data, '\2*.tif');
            image = dir(filesImage);
            namesImage = {image.name};

            %ciclo eseguito per ogni immagine all'interno della cartella
            %rappresentante ciascuna data delle immagini disponibili
            for j = 1:length(namesImage)
                
                dataset(st).DatiImmagini(i).Data = data;
                
                %vengono estratti i valori reali di soil moisture per la
                %data in esame
                [dataset(st).DatiImmagini(i).RealSM, dataset(st).DatiImmagini(i).monthlySM] = extractRealSM(dirStazioni, stazione, data);
                
                dataset(st).DatiImmagini(i).B4 = nan;
                dataset(st).DatiImmagini(i).B8 = nan;
                try
                    %estrazione dei valori delle riflettanze per la
                    %stazione st-esima nella data i-esima
                    bands = loadDataFromImage(lat, lon, r, strcat(dirImage, '\', data, '\', char(namesImage(j))), ["B4", "B8"], 'Sentinel');

                    %memorizzazione dei valori delle riflettanze estratti
                    %all'interno dei campi del dataset appositi
                    dataset(st).DatiImmagini(i).B4 = bands.B4;
                    dataset(st).DatiImmagini(i).B8 = bands.B8;
                    
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
    save(strcat(dirData, '\datasetSentinel.mat'), 'dataset');
    
    waitbar(1, h, 'Finished');
    close(h);
end