function [SM, dayTable] = extractRealSM(directory, station, data)
%Funzione per l'estrazione dei valori di SM acquisiti in situ.
%Permette di estrarre per una determinata stazione, il valore rilevato di
%Soil Moisture in situ per la data specificata e i valori riguardanti i 15
%giorni precedenti e i 15 giorni successivi a tale data.
%
% directory: posizione dei file excel contenenti i dati per ciascuna stazione
% station: codice della stazione di cui si vogliono i dati di SM in situ
% data: la data di interesse

    %lettura del file excel riguardante la stazione di interesse
    tabella = importfile(strcat(directory, '/', station, '.xlsx'), 'Table 1', 10, 10870);
    toDelete = isnan(tabella.USI);
    tabella(toDelete,:) = [];

    %ciclo eseguito per tutte le righe della tabella
    for i=1:height(tabella)
        %replicazione delle date per tutte le righe in maniera opportuna
        if(tabella.Data(i) == "")
            tabella.Data(i) = tabella.Data(i-1);
        end
    end

    %definizione di una tabella contenente solo le date e i valori di SM
    date = datetime(tabella.Data, 'InputFormat', 'dd/MM/yyyy');
    T = table(date, tabella.USI, 'VariableNames', {'data', 'SM'});
    
    %estrazione del valore di SM per la data di interesse
    day = datetime(data,'InputFormat','yyyy-MM-dd');
    [row,~] = find(T.data == day);
    
    %estrazione dei valori di SM nell'intervallo di tempo che va da 15
    %giorni prima della data di interesse a 15 giorni dopo tale data
    SM = mean(table2array(T(row, 2)));
    if(height(T)<row+360)
        dayTable = table2struct(T(row-360:height(T),:));
    elseif (row-360 < 0)
        dayTable = table2struct(T(1:row+360,:));
    else
        dayTable = table2struct(T(row-360:row+360,:));
    end

end


