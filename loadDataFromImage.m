function data = loadDataFromImage(lat, lon, radius, imageFilename, bands, sensor)
%Funzione che si occupa dell'estrazione dei valori di riflettanza dei pixel
%di un'immagine satellitare multibanda riguardanti un'area quadrata
%centrata in determinate coordinate (lat,lon) e avente determinato raggio (r).
%
% lat, lon: latitudine e longitudine del punto centrale della zona d'interesse
% radius: raggio in numero di pixel della ROI.
% imageFilename: nome dell'immagine satellitare multibanda in formato GeoTiff
% bands: nomi delle bande presenti nell'immagine
% sensor: tipo di sensore utilizzato per l'acquisizione dell'immagine in esame

    %controllo sul numero di parametri e assegnazione del valore di default
    %per il tipo di sensore se non specificato  
    if(nargin == 6 && ~isempty(sensor))
        if(~(strcmp(sensor, 'Sentinel')) && ~(strcmp(sensor, 'Landsat')))
            %valori del sensore diversi da Sentinel o Landsat producono un
            %errore
            error(char("Sensore non riconosciuto, i valori supportati sono 'Sentinel' e 'Landsat'"));
        end
    else
        sensor = 'Landsat';
    end
    
    %calcolo del numero di bande atteso
    bandsNumber = length(bands);

    %lettura dell'immagine geotiff e la rispettiva matrice di referenziazione
    [image, R] = geotiffread(imageFilename);

    %adeguamento del numero di dimensioni dell'immagine caricata
    if(ndims(image) == 2)
        S = [size(image), 1];
        image = reshape(image, S);
    end
    
    %controllo sul numero di bande atteso ed effettivo dell'immagine
    if(size(image,3) ~= bandsNumber)
        %la non corrispondenza produce un errore
        error(char("Numero delle bande specificato diverso da quello delle bande presenti nell'immagine"));
    end
        
    %operazioni di adeguamento dei valori delle riflettanze in base al
    %sensore di acquisizione utilizzato per l'immagine
    if(strcmp(sensor, 'Sentinel'))
        image = double(image)/10000;
        image(image==0) = NaN;
    elseif(strcmp(sensor, 'Landsat'))
        image = double(image);
    end
    
    %conversione delle coordinate Lat/Lon del centro della ROI nelle
    %corrispettive coordinate UTM
    [X, Y] = ll2utm(lat, lon, 33);
    
    %calcolo delle coordinate del pixel in cui ricade il centro della ROI
    [rowCenter, colCenter] = map2pix(R, X, Y);
    rowCenter = ceil(rowCenter);
    colCenter = ceil(colCenter);
    
    %inizializzazione della struttura dati per la memorizzazione delle
    %informazioni estratte dall'immagine
    data = struct('PixelCoord', []);
    
    %controllo sulla validità del pixel centrale della ROI
    if(rowCenter > 0 && rowCenter <= size(image,1) && colCenter > 0 && colCenter <= size(image,2) && ~isnan(image(ceil(rowCenter),ceil(colCenter))))
        %Il centro della ROI risulta interno all'immagine e il suo valore
        %di riflettanza è valido
        
        %calcolo delle coordinate di tutti i pixel all'interno della ROI
        coord = combvec(rowCenter - radius : rowCenter + radius, colCenter - radius : colCenter + radius); 
        data.PixelCoord = coord';
        
        %ciclo eseguito su tutte le bande dell'immagine
        for j=1:bandsNumber
            
            %estrazione dei valori di riflettanza della banda j-esima
            %dell'immagine
            band = squeeze(image(:,:,j));
            
            %calcolo del subset dell'immagine corrispondente alla ROI
            subset = band(rowCenter - radius : rowCenter + radius, colCenter - radius : colCenter + radius);
            
            %memorizzazione del subset nel campo della struttura dati adeguato 
            data.(char(bands(j))) = subset(:);
        end
        
    elseif(rowCenter <= 0 || rowCenter > size(image,1) || colCenter <= 0 || colCenter > size(image,2))
        %il centro della ROI non rientra nell'immagine
        
        %generazione e lancio dell'eccezione corrispondente
        OutOfBound = MException('loadDataFromImage:outOfBound', char("Stazione fuori dai limiti dell'immagine"));     
        throw(OutOfBound);
    elseif(isnan(image(rowCenter,colCenter)))
        %il centro della ROI ha un valore di riflettanza non valido
        
        %generazione e lancio dell'eccezione corrispondente
        NoDataStation = MException('loadDataFromImage:noDataStation', char("Il pixel della stazione ha valore non valido"));
        throw(NoDataStation);
    end    
end