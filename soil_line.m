function [P, I] = soil_line(M, n, sl_flag)
%Funzione per il calcolo della Soil Line.
%Il calcolo della Soil Line consiste nella suddivisione dei pixel nello
%spazio Red-NIR in un numero di intervalli predefinito per valori via via 
%crescenti della riflettanza sulla banda NIR. Vengono individuati, per 
%ciascuno degli intervalli, i pixel aventi riflettanza sulla banda Red
%minore e utilizzati per ottenere, tramite regressione lineare, pendenza e 
%intercetta per la Soil Line.
% 
% M: matrice di pixel su cui calcolare la Soil Line
% n: numero di intervalli in cui suddividere i dati
% sl_flag: flag per la visualizzazione del grafico del modello ottenuto dalla regressione lineare
    
    i=0;
    
    %calcolo dell'ampiezza degli intervalli, prendendo il valore massimo
    %dell'ascissa e dividendolo per il numero di intervalli
    f = max(M(:,1))/n;
    
    %eliminazione dei pixel aventi valori di riflettanza nelle bande Red o
    %NIR inferiori o pari a 0 oppure superiori a 1
    M(M(:,1) <= 0 | M(:,1) > 1) = [];
    M(M(:,2) <= 0 | M(:,2) > 1) = [];
    
    %eliminazione degli outliers
    outIndex = isoutlier(M(:,2),1);
    M(outIndex,:) = [];
    
    %inizializzazione dell'array che conterrà i pixel con NIR minimo per
    %ogni intervallo
    Dati = [];
    
    %per ogni intervallo trova il pixel con valore di riflettanza nella 
    %banda NIR minimo
    while i<n
        SB = M(M(:,1)<=i+f & M(:,1)>i,:);
        if numel(SB)>0
            mn = min(SB(:,2));
            if mn < 1
                Dati = [Dati; SB(SB(:,2)==mn,:)];
            end
        end
        i = i+f;
    end
    
    x = Dati(:,1);
    y = Dati(:,2);
    Mat = [x,y];
    
    %eliminazione degli outliers
    outIndex = isoutlier(Mat(:,2), 1);
    Mat(outIndex,:) = [];
    
    %eliminazione dei pixel aventi riflettanza nella banda Red inferiore a
    %quella del pixel con ordinata minima
    [~, i] = min(Mat(:,2));
    Mat(1:i,:) = [];
    
    %realizzazione della regressione lineare per la stima di pendenza e
    %intercetta della Soil Line
    mdl = fitlm(Mat(:,1), Mat(:,2));
    
    %estrazione dei coefficienti dal modello
    b = mdl.Coefficients.Estimate;
    
    %selezione di intercetta e pendenza della Soil Line
    I = b(1);
    P = b(2);
    
    %visualizzazione del grafico del modello ottenuto dalla regressione
    %lineare rappresentante la Soil Line trovata
    if(sl_flag)
        hold on;
        plot(mdl);
        hold off;
    end
    
end