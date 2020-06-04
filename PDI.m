function result = PDI(dataset, sl_flag)
%Funzione per l'applicazione del metodo del Perpendicular Drought Index. 
%Il metodo sfrutta le informazioni contenute all'interno del dataset
%passato in input alla funzione per ottenere valori per l'indice PDI
%utilizzabili al fine di stimare i valori di Soil Moisture.
% 
% dataset: struttura dati contenente tutte le informazioni di interesse per l'applicazione del metodo
% sl_flag: flag per la visualizzazione dei grafici a dispersione degli spazi Red-NIR con soil line

    %inizializzazione della struttura dati per la memorizzazione delle
    %informazioni ottenute dall'applicazione del metodo per ciascuna
    %stazione presente nel dataset
    result = struct('Stazione', {}, 'Data', {}, 'PDI', {}, 'PDI_matrix', {}, 'PDI_point', {}, 'SM', {}, 'SM_matrix', {}, 'SM_point', {}, 'RealSM', {}, 'monthlySM', {});
    
    id = 0;
    
    %ciclo eseguito su tutte le stazioni presenti nel dataset
    for st = 1:length(dataset)
        
        %estrazione dal dataset dei valori di capacità di campo e
        %appassimento riguardanti la stazione in esame
        Wp_min = dataset(st).DatiSuolo.CA;
        Wh_max = dataset(st).DatiSuolo.CC;

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
            
            %estrazione dei valori di riflettanza per le bande 4 e 8
            %dell'immagine in esame e riguardanti la stazione considerata
            B4_vector = cat(1, dataset(st).DatiImmagini(i).B4);
            B8_vector = cat(1, dataset(st).DatiImmagini(i).B8);
            
            %controllo della validità dei valori di riflettanza estratti
            %dal dataset in precedenza
            if(length(B4_vector) > 1)
                %valori di riflettanza validi
                
                %sostituzione dei valori superiori a 1 con 1
                B4_vector(B4_vector>1)=1;
                B8_vector(B8_vector>1)=1;
                
                %rappresentazione dei dati attraverso un grafico a
                %dispersione nello spazio Red-NIR
                if(sl_flag)
                    figure;
                    scatter(B4_vector, B8_vector);
                    hold on;
                end

                %calcolo della Soil Line 
                [P, ~] = soil_line([B4_vector, B8_vector], 50, sl_flag);

                %calcolo del valore del PDI per ciascun pixel attraverso 
                %l'utilizzo delle riflettanze estratte in precedenza
                %e il valore della pendenza della Soil Line
                result(id).PDI = (1/sqrt(P^2 + 1))*(B4_vector + P*B8_vector);

                %normalizzazione del PDI
                result(id).PDI = (result(id).PDI - nanmin(result(id).PDI(:))) / (nanmax(result(id).PDI(:)) - nanmin(result(id).PDI(:)));

                %calcolo dei valori di Soil Moisture facendo uso dei valori
                %di PDI calcolati in precedenza e i valori di capacità di 
                %campo e appassimento riguardanti la stazione in esame
                result(id).SM = Wp_min + ((1 - result(id).PDI) .* (Wh_max - Wp_min));

                r = dataset(st).Raggio;
                mis = [(2*r)+1, (2*r)+1];
                
                %si realizzano le matrici di pixel con valori di PDI e SM e
                %si estraggono i rispettivi valori centrali, corrispondenti
                %ai pixel su cui si trova la stazione in esame
                result(id).PDI_matrix = reshape(cat(1, result(id).PDI), mis);
                result(id).PDI_point = result(id).PDI_matrix(r+1, r+1);

                result(id).SM_matrix = reshape(cat(1, result(id).SM), mis)*100;
                result(id).SM_point = result(id).SM_matrix(r+1, r+1);

            else
                %valori di riflettanza non validi
                
                %assegnazione di valori non validi per PDI e SM
                result(id).PDI = nan;
                result(id).PDI_matrix = nan;
                result(id).PDI_point = nan;
                
                result(id).SM = nan;
                result(id).SM_matrix = nan;
                result(id).SM_point = nan;
            end
            
        end
    end
    
    %eliminazione dai risultati degli elementi per cui non è stato
    %possibile ottenere un valore valido per la stima della Soil Moisture
    result = result(~isnan(cat(1,result(:).SM_point)));
end