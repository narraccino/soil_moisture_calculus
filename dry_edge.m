function [P, I] = dry_edge(M, n, g_flag)
%Funzione per il calcolo del Dry Edge.
%Il calcolo del Dry Edge consiste nella suddivisione dei pixel nello
%spazio LST-NDVI in un numero di intervalli predefinito per valori via via 
%crescenti di NDVI. Vengono individuati, per ciascuno degli intervalli, i 
%pixel aventi LST maggiore e utilizzati per ottenere, tramite regressione 
%lineare, pendenza e intercetta del Dry Edge.
% 
% M: matrice di pixel su cui calcolare il Dry Edge
% n: numero di intervalli in cui suddividere i dati
% sl_flag: flag per la visualizzazione del grafico del modello ottenuto dalla regressione lineare

    i=0;
    
    %calcolo dell'ampiezza degli intervalli, prendendo il valore massimo
    %dell'ascissa e dividendolo per il numero di intervalli
    f = max(M(:,1))/n;
    
    %inizializzazione dell'array che conterrà i pixel con NIR minimo per
    %ogni intervallo
    Dati = [];
    
    %per ogni intervallo trova il pixel con valore di LST massimo
    while i<n
        SB = M(M(:,1)<=i+f & M(:,1)>i,:);
        if numel(SB)>0
            mn = max(SB(:,2));
            Dati = [Dati; SB(SB(:,2)==mn,:)];
        end
        i = i+f;
    end
    
    x = Dati(:,1);
    y = Dati(:,2);
    Mat = [x,y];
    
    %eliminazione degli outliers
    outIndex = isoutlier(Mat(:,2), 1);
    Mat(outIndex,:) = [];
    
    %eliminazione dei pixel aventi NDVI inferiore a quello del pixel 
    %con ordinata massima
    [~, i] = max(Mat(:,2));
    Mat(1:i,:) = [];
    
    %realizzazione della regressione lineare per la stima di pendenza e
    %intercetta del Dry Edge
    mdl = fitlm(Mat(:,1), Mat(:,2));
    
    %estrazione dei coefficienti dal modello
    b = mdl.Coefficients.Estimate;
    
    %selezione di intercetta e pendenza del Dry Edge
    I = b(1);
    P = b(2);
    
    %visualizzazione del grafico del modello ottenuto dalla regressione
    %lineare rappresentante il Dry Edge trovato 
    if(g_flag)
        hold on
        plot(mdl);
    end
    
end
            