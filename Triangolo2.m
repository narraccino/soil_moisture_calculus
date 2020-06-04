function result = Triangolo2(dataset)
%Funzione per l'applicazione del secondo metodo del triangolo.
%Il metodo sfrutta le informazioni contenute all'interno del dataset
%passato in input alla funzione per calcolare il valore di FVC e
%temperatura normalizzata per tutte le immagini di tutte le stazioni al
%fine di utilizzarne una parte per la generazione dei coefficienti
%del modello per la stima della SSM. Le stime ottenute con tale modello
%vengono poi raccolte, insieme alle altre informazioni, in una struttura
%dati restituita in output dalla funzione.
% 
% dataset: struttura dati contenente tutte le informazioni di interesse per l'applicazione del metodo

    %inizializzazione della struttura dati per la memorizzazione delle
    %informazioni ottenute dall'applicazione del metodo per ciascuna
    %stazione presente nel dataset
    result = struct('Stazione', {}, 'Data', {}, 'FVC', {}, 'Tn', {}, 'SSM', {}, 'RealSM', {}, 'monthlySM', {});

    id = 0;
    
    %ciclo eseguito su tutte le stazioni presenti nel dataset
    for st = 1:length(dataset)
        
        %valori di massimo e minimo dell'NDVI
        NDVI_min = 0.2;
        NDVI_max = 0.86;

        %calcolo dei valori di massimo e minimo delle LST della stazione in
        %esame
        Tmp_max = max(cat(1, dataset(st).DatiImmagini(:).LSTMEAN));
        Tmp_min = min(cat(1, dataset(st).DatiImmagini(:).LSTMEAN));

        r = dataset(st).Raggio;
        mis = [(2*r)+1, (2*r)+1];
        
        %ciclo eseguito su tutti i dati ottenuti dalle immagini e 
        %riguardanti la stazione in esame 
        for i = 1:length(dataset(st).DatiImmagini)
            id = id + 1;
            
            %estrazione dal dataset delle informazioni su stazione e data 
            %per cui si vuole effettuare la stima della Soil Moisture
            result(id).Stazione = dataset(st).Stazione;
            result(id).Data = dataset(st).DatiImmagini(i).Data;
            
            %controllo sulla validità dei dati considerati
            if(length(dataset(st).DatiImmagini(i).NDVI) > 1)
                %dati validi
                
                %estrazione del valore di NDVI riguardante il pixel della
                %stazione in esame ottenuto dall'immagine i-esima
                NDVI_matrix = reshape(cat(1, dataset(st).DatiImmagini(i).NDVI), mis);
                NDVI_point = NDVI_matrix(r+1, r+1);
                
                %calcolo del Fractional Vegetation Cover
                result(id).FVC = ((NDVI_point - NDVI_min)/(NDVI_max - NDVI_min)).^2;
                
                %estrazione del valore di LST riguardante il pixel della
                %stazione in esame ottenuto dall'immagine i-esima
                Tn_matrix = reshape(cat(1, dataset(st).DatiImmagini(i).LSTMEAN), mis);
                T_point = Tn_matrix(r+1, r+1);
                
                %normalizzazione della temperatura
                result(id).Tn = (T_point - Tmp_min)/(Tmp_max - Tmp_min);
                
                %estrazione dei dati di Soil Moisture reali riguardanti la
                %stazione e la data considerate
                result(id).RealSM = dataset(st).DatiImmagini(i).RealSM;
                result(id).monthlySM = dataset(st).DatiImmagini(i).monthlySM;
                
            else
                %dati non validi
                
                %assegnazione di valori non validi per FVC e temperatura
                %normalizzata
                result(id).FVC = nan;
                result(id).Tn = nan;
            end 

        end   
                
    end
    
    %eliminazione dai risultati degli elementi per cui non è stato
    %possibile ottenere un valore valido per FVC e temperatura normalizzata
    result = result(~isnan(cat(1, result(:).FVC)));
    
    %selezione del training set formato dal 70% dei dati totali raccolti
    indexes = randperm(length(result), round(length(result)*0.70));
    trainingSet = result(indexes);
    
    %definizione di "predictor variables" e "response variables" da
    %utilizzare per effettuare la regressione lineare al fine di ottenere i
    %coefficienti del modello quadratico per la stima di SSM
    Xc = [cat(1, trainingSet(:).FVC), cat(1, trainingSet(:).Tn)];
    yc = cat(1, trainingSet(:).RealSM);
    
    %realizzazione del modello tramite regressione lineare quadratica
    mdl = fitlm(Xc,yc,'quadratic');
    
    %estrazione dei coefficienti del modello realizzato
    coff = mdl.Coefficients.Estimate;
    
    %ciclo eseguito su tutti i risultati
    for i = 1:length(result)
        %stima della Soil Moisture superficiale attraverso il modello
        %quadratico per ciascuna stazione di cui si hanno informazioni
        %valide all'interno del dataset
        result(i).SSM = coff(1) + coff(2)*result(i).FVC + coff(3)*result(i).Tn + coff(4)*(result(i).Tn .* result(i).FVC) + coff(5)*(result(i).FVC.^2) + coff(6)*(result(i).Tn.^2);
    end

end