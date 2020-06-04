function result = MPDI(dataset, sl_flag)
%Funzione per l'applicazione del metodo del Modified Perpendicular Drought Index. 
%Il metodo sfrutta le informazioni contenute all'interno del dataset
%passato in input alla funzione per ottenere valori per l'indice MPDI
%utilizzabili al fine di stimare i valori di Soil Moisture.
% 
% dataset: struttura dati contenente tutte le informazioni di interesse per l'applicazione del metodo
% sl_flag: flag per la visualizzazione dei grafici a dispersione degli spazi Red-NIR con soil line

    %inizializzazione della struttura dati per la memorizzazione delle
    %informazioni ottenute dall'applicazione del metodo per ciascuna
    %stazione presente nel dataset
    result = struct('Stazione', {}, 'Data', {}, 'MPDI', {}, 'MPDI_matrix', {}, 'MPDI_point', {}, 'SM', {}, 'SM_matrix', {}, 'SM_point', {}, 'RealSM', {}, 'monthlySM', {});
    
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
                
                %calcolo dell'NDVI con i valori di riflettanza estratti
                NDVI_vector = (B8_vector - B4_vector) ./ (B8_vector + B4_vector);
                
                %calcolo dei valori massimi e minimi di NDVI 
                NDVI_max = nanmax(NDVI_vector);
                NDVI_min = nanmin(NDVI_vector(NDVI_vector>0.1));
                
                %calcolo del Fraction Vegetation
                fv = 1 - (((NDVI_max - NDVI_vector)./(NDVI_max - NDVI_min)).^0.6175);
                fv = real(fv);
                
                %valori di riflettanza per pixel con alta copertura
                %vegetativa nelle bande del rosso e del vicino-infrarosso
                Rv_red = 0.05;
                Rv_NIR = 0.5;

                %calcolo del valore dell'MPDI per ciascun pixel attraverso 
                %l'utilizzo delle riflettanze estratte in precedenza, il 
                %valore della pendenza della Soil Line, il valore del
                %Fraction Vegetation calcolato e i valori di riflettanza
                %per pixel con alta copertura vegetativa nelle bande del
                %rosso e del vicino-infrarosso
                result(id).MPDI = (B4_vector + P*B8_vector - (fv.*(Rv_red + P*Rv_NIR))) ./ ((1-fv).*sqrt(P^2 + 1));

                %normalizzazione dell'MPDI
                MPDI_min = nanmin(result(id).MPDI(result(id).MPDI(:) > -0.2));
                MPDI_max = nanmax(result(id).MPDI(result(id).MPDI(:) < 1.2));
                result(id).MPDI = (result(id).MPDI - MPDI_min) / (MPDI_max - MPDI_min);

                %calcolo dei valori di Soil Moisture facendo uso dei valori
                %di MPDI calcolati in precedenza e i valori di capacità di 
                %campo e appassimento riguardanti la stazione in esame
                result(id).SM = Wp_min + ((1 - result(id).MPDI) .* (Wh_max - Wp_min));

                r = dataset(st).Raggio;
                mis = [(2*r)+1, (2*r)+1];

                %si realizzano le matrici di pixel con valori di PDI e SM e
                %si estraggono i rispettivi valori centrali, corrispondenti
                %ai pixel su cui si trova la stazione in esame
                result(id).MPDI_matrix = reshape(cat(1, result(id).MPDI), mis);
                result(id).MPDI_point = result(id).MPDI_matrix(r+1, r+1);

                result(id).SM_matrix = reshape(cat(1, result(id).SM), mis)*100;
                result(id).SM_point = result(id).SM_matrix(r+1, r+1);

            else
                %valori di riflettanza non validi
                
                %assegnazione di valori non validi per MPDI e SM
                result(id).MPDI = nan;
                result(id).MPDI_matrix = nan;
                result(id).MPDI_point = nan;
                
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