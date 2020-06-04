function result = Triangolo(dataset, g_flag)
%Funzione per l'applicazione del primo metodo del triangolo.
%Il metodo sfrutta le informazioni contenute all'interno del dataset
%passato in input alla funzione per realizzare uno spazio triangolare
%LST-NDVI, attraverso il quale è possibile ottenere valori per l'indice SWI
%utilizzabili al fine di stimare i valori di Soil Moisture.
% 
% dataset: struttura dati contenente tutte le informazioni di interesse per l'applicazione del metodo
% g_flag: flag per la visualizzazione dei grafici a dispersione degli spazi triangolari LST-NDVI con dry edge

    %inizializzazione della struttura dati per la memorizzazione delle
    %informazioni ottenute dall'applicazione del metodo per ciascuna
    %stazione presente nel dataset
    result = struct('Stazione', {}, 'Data', {}, 'SWI', {}, 'SWI_matrix', {}, 'SWI_point', {}, 'SM', {}, 'SM_matrix', {}, 'SM_point', {}, 'RealSM', {});

    id = 0;
    
    %ciclo eseguito su tutte le stazioni presenti nel dataset
    for st = 1:length(dataset)
        
        %estrazione dal dataset dei valori di capacità di campo e
        %appassimento riguardanti la stazione in esame
        Wp_min = dataset(st).DatiSuolo.CA;
        Wh_max = dataset(st).DatiSuolo.CC;

        %rappresentazione dei dati attraverso un grafico a dispersione
        %nello spazio triangolare LST-NDVI
        if(g_flag)
            figure;
            scatter(cat(1, dataset(st).DatiImmagini(:).NDVI), cat(1, dataset(st).DatiImmagini(:).LSTMEAN));
            hold on;
        end

        %calcolo del Dry Edge del triangolo formato dai dati nello spazio
        %triangolare LST-NDVI
        [b, a] = dry_edge([cat(1, dataset(st).DatiImmagini(:).NDVI), cat(1, dataset(st).DatiImmagini(:).LSTMEAN)], 50, g_flag);
        
        %calcolo della temperatura minima, rappresentante il Wet Edge del
        %triangolo formato dai dati nello spazio triangolare LST-NDVI
        T_min = min(cat(1, dataset(st).DatiImmagini(:).LSTMEAN));

        %ciclo eseguito su tutti i dati ottenuti dalle immagini e 
        %riguardanti la stazione in esame
        for i = 1:length(dataset(st).DatiImmagini)
            id = id + 1;
            
            %estrazione dal dataset delle informazioni su stazione e data 
            %per cui si vuole effettuare la stima della Soil Moisture
            result(id).Data = dataset(st).DatiImmagini(i).Data;
            result(id).Stazione = dataset(st).Stazione;
            
            %estrazione dei dati di Soil Moisture reali riguardanti la
            %stazione e la data considerate
            result(id).RealSM = dataset(st).DatiImmagini(i).RealSM;
            result(id).monthlySM = dataset(st).DatiImmagini(i).monthlySM;
            
            %calcolo dei valori dell'indice SWI per ciascun pixel
            %attraverso l'utilizzo dei dati su NDVI e LST media riguardanti
            %la stazione e la data in esame, estratti dal dataset e i
            %valori di pendenza e intercetta del Dry Edge
            result(id).SWI = ((a+b*dataset(st).DatiImmagini(i).NDVI) - dataset(st).DatiImmagini(i).LSTMEAN) ./ ((a+b*dataset(st).DatiImmagini(i).NDVI) - T_min);

            %calcolo dei valori di Soil Moisture facendo uso dei valori di
            %SWI calcolati in precedenza e i valori di capacità di campo e
            %appassimento riguardanti la stazione in esame
            result(id).SM = Wp_min + (result(id).SWI .* (Wh_max - Wp_min));

            r = dataset(st).Raggio;
            mis = [(2*r)+1, (2*r)+1];

            %se i vettori SWI e SM calcolati hanno un numero di elementi
            %superiore a 1
            if length(result(id).SWI) > 1
                %si realizzano le matrici di pixel con valori di SWI e SM e
                %si estraggono i rispettivi valori centrali, corrispondenti
                %ai pixel su cui si trova la stazione in esame
                result(id).SWI_matrix = reshape(cat(1, result(id).SWI), mis);
                result(id).SWI_point = result(id).SWI_matrix(r+1, r+1);

                result(id).SM_matrix = reshape(cat(1, result(id).SM), mis)*100;
                result(id).SM_point = result(id).SM_matrix(r+1, r+1);
            else
                %altrimenti si è in presenza di valori non validi di SWI e
                %SM, i quali vengono copiati nelle corrispettive variabili
                %adibite a contenere le matrici e i punti centrali
                result(id).SWI_matrix = result(id).SWI;
                result(id).SWI_point = result(id).SWI;
                
                result(id).SM_matrix = result(id).SM;
                result(id).SM_point = result(id).SM;
            end


        end
    end
    
    %eliminazione dai risultati degli elementi per cui non è stato
    %possibile ottenere un valore valido per la stima della Soil Moisture
    result = result(~isnan(cat(1,result(:).SM_point)));
end