function showGraphics(stations)
%Funzione per la generazione dei grafici sull'andamento temporale della SM.
%Viene generato per ogni stazione desiderata un grafico contenente il
%confronto tra l'andamento nel tempo dei valori reali di SM e quelli
%stimati da ciascun algoritmo.
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

        %creazione grafico sull'andamento temporale della SM
        figure;
        monthly = cat(1, pdi_staz(:).monthlySM, tri1_staz(:).monthlySM);
        [~, ord] = sort([monthly(:).data]);
        monthly = monthly(ord);
        hold on
        %aggiunta degli andamenti mensili dei valori reali di SM al grafico
        plot(cat(1, monthly.data), cat(1, monthly.SM))
        %aggiunta dei dati stimati per l'algoritmo PDI
        plot(datetime(cat(1, pdi_staz(:).Data), 'InputFormat', 'yyyy-MM-dd'), cat(1, pdi_staz(:).SM_point), 'LineStyle', '--', 'Marker', 'o' )
        %aggiunta dei dati stimati per l'algoritmo MPDI
        plot(datetime(cat(1, mpdi_staz(:).Data), 'InputFormat', 'yyyy-MM-dd'), cat(1, mpdi_staz(:).SM_point), 'LineStyle', '--', 'Marker', '*' )
        %aggiunta dei dati stimati per il primo metodo del triangolo
        plot(datetime(cat(1, tri1_staz(:).Data), 'InputFormat', 'yyyy-MM-dd'), cat(1, tri1_staz(:).SM_point), 'LineStyle', ':', 'Marker', 'd' )
        %aggiunta dei dati stimati per il secondo metodo del triangolo
        plot(datetime(cat(1, tri2_staz(:).Data), 'InputFormat', 'yyyy-MM-dd'), cat(1, tri2_staz(:).SSM), 'LineStyle', '-.', 'Marker', 'x' )

        title(strcat('Andamento Soil Moisture Stazione 0PU', int2str(st)));
        xlabel('Date');
        ylabel('Soil Moisture (%)');
        grid on;
        legend('Soil Moisture reale', 'PDI', 'MPDI', 'Triangolo1', 'Triangolo2');
    end

end