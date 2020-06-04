function showScatter(stations)
%Funzione per la generazione degli scatter plot per ogni stazione selezionata.
%Viene generato per ogni stazione desiderata uno scatter plot contenente il
%confronto tra i diversi parametri calcolati (indici e stime) e i valori 
%reali di SM.
%
% stations: vettore contenente i codici delle stazioni da selezionare

    %caricamento del dataset Sentinel
    datasetSentinel = importdata('..\Dati\datasetSentinel.mat');
    %calcolo dei risultati ottenuti dall'applicazione degli algoritmi PDI e MPDI
    pdi = PDI(datasetSentinel, false);
    mpdi = MPDI(datasetSentinel, false);

    %caricamento del dataset Landsat
    datasetLandsat = importdata('..\Dati\datasetLandsat.mat');
    %calcolo dei risultati ottenuti dall'applicazione del primo e del
    %secondo metodo del triangolo
    tri1 = Triangolo(datasetLandsat, false);
    tri2 = Triangolo2(datasetLandsat);

    %ciclo eseguito su tutte le stazioni desiderate
    for st = stations
        
        %estrazione dei dati riguardanti la stazione in esame per tutti gli
        %algoritmi
        pdi_staz = pdi([pdi.Stazione]==strcat('0PU',int2str(st)));
        mpdi_staz = mpdi([mpdi.Stazione]==strcat('0PU',int2str(st)));
        tri1_staz = tri1([tri1.Stazione]==strcat('0PU',int2str(st)));
        tri2_staz = tri2([tri2.Stazione]==strcat('0PU',int2str(st)));

        %creazione dello scatter plot che confronta valori di PDI e i 
        %valori di SM reali
        figure;
        md1 = fitlm(cat(1,pdi_staz(:).RealSM), cat(1,pdi_staz(:).PDI_point));
        plot(md1);
        grid on;
        title(strcat('Scatter PDI - Soil Moisture in situ - Stazione 0PU',int2str(st)));
        ylabel('PDI');
        xlabel('Soil Moisture in situ (%)');
        
        %creazione dello scatter plot che confronta valori di MPDI e i
        %valori di SM reali
        figure;
        md2 = fitlm(cat(1,mpdi_staz(:).RealSM), cat(1,mpdi_staz(:).MPDI_point));
        plot(md2);
        grid on;
        title(strcat('Scatter MPDI - Soil Moisture in situ - Stazione 0PU',int2str(st)));
        ylabel('MPDI');
        xlabel('Soil Moisture in situ (%)');
        
        %creazione dello scatter plot che confronta valori di SM stimati
        %con l'algoritmo del PDI e i valori di SM reali
        figure;
        md3 = fitlm(cat(1,pdi_staz(:).RealSM), cat(1,pdi_staz(:).SM_point));
        plot(md3);
        grid on;
        title(strcat('Scatter PDI Soil Moisture - Soil Moisture in situ - Stazione 0PU',int2str(st)));
        ylabel('PDI Soil Moisture (%)');
        xlabel('Soil Moisture in situ (%)');
        
        %creazione dello scatter plot che confronta valori di SM stimati
        %con l'algoritmo del MPDI e i valori di SM reali
        figure;
        md4 = fitlm(cat(1,mpdi_staz(:).RealSM), cat(1,mpdi_staz(:).SM_point));
        plot(md4);
        grid on;
        title(strcat('Scatter MPDI Soil Moisture - Soil Moisture in situ - Stazione 0PU',int2str(st)));
        ylabel('MPDI Soil Moisture (%)');
        xlabel('Soil Moisture in situ(%)');
        
        %creazione dello scatter plot che confronta valori di SWI e i
        %valori di SM reali
        figure;
        md1 = fitlm(cat(1,tri1_staz(:).RealSM), cat(1,tri1_staz(:).SWI_point));
        plot(md1);
        grid on;
        title(strcat('Scatter SWI - Soil Moisture in situ - Stazione 0PU',int2str(st)));
        ylabel('SWI');
        xlabel('Soil Moisture in situ(%)');
        
        %creazione dello scatter plot che confronta valori di SM stimati
        %con il primo metodo del triangolo e i valori di SM reali
        figure;
        md2 = fitlm(cat(1,tri1_staz(:).RealSM), cat(1,tri1_staz(:).SM_point));
        plot(md2);
        grid on;
        title(strcat('Scatter Triangolo1 Soil Moisture - Soil Moisture in situ - Stazione 0PU',int2str(st)));
        ylabel('Triangolo1 Soil Moisture (%)');
        xlabel('Soil Moisture in situ(%)');
        
        %creazione dello scatter plot che confronta valori di SM stimati
        %con il secondo metodo del triangolo e i valori di SM reali
        figure;
        md3 = fitlm(cat(1,tri2_staz(:).RealSM), cat(1,tri2_staz(:).SSM));
        plot(md3);
        grid on;
        title(strcat('Scatter Triangolo2 Soil Moisture - Soil Moisture in situ - Stazione 0PU',int2str(st)));
        ylabel('Triangolo2 Soil Moisture (%)');
        xlabel('Soil Moisture in situ(%)');
    end

end
