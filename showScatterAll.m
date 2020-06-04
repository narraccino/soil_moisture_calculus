clear;

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

%creazione dello scatter plot che confronta valori di PDI e i 
%valori di SM reali
figure;
md1 = fitlm(cat(1,pdi(:).RealSM), cat(1,pdi(:).PDI_point));
plot(md1);
grid on;
title('Scatter PDI - Soil Moisture in situ');
ylabel('PDI');
xlabel('Soil Moisture in situ (%)');

%creazione dello scatter plot che confronta valori di MPDI e i
%valori di SM reali
figure;
md2 = fitlm(cat(1,mpdi(:).RealSM), cat(1,mpdi(:).MPDI_point));
plot(md2);
grid on;
title('Scatter MPDI - Soil Moisture in situ');
ylabel('MPDI');
xlabel('Soil Moisture in situ (%)');

%creazione dello scatter plot che confronta valori di SM stimati
%con l'algoritmo del PDI e i valori di SM reali
figure;
md3 = fitlm(cat(1,pdi(:).RealSM), cat(1,pdi(:).SM_point));
plot(md3);
grid on;
title('Scatter PDI Soil Moisture - Soil Moisture in situ');
ylabel('PDI Soil Moisture (%)');
xlabel('Soil Moisture in situ (%)');

%creazione dello scatter plot che confronta valori di SM stimati
%con l'algoritmo del MPDI e i valori di SM reali
figure;
md4 = fitlm(cat(1,mpdi(:).RealSM), cat(1,mpdi(:).SM_point));
plot(md4);
grid on;
title('Scatter MPDI Soil Moisture - Soil Moisture in situ');
ylabel('MPDI Soil Moisture (%)');
xlabel('Soil Moisture in situ(%)');

%creazione dello scatter plot che confronta valori di SWI e i
%valori di SM reali
figure;
md1 = fitlm(cat(1,tri1(:).RealSM), cat(1,tri1(:).SWI_point));
plot(md1);
grid on;
title('Scatter SWI - Soil Moisture in situ');
ylabel('SWI');
xlabel('Soil Moisture in situ(%)');

%creazione dello scatter plot che confronta valori di SM stimati
%con il primo metodo del triangolo e i valori di SM reali
figure;
md2 = fitlm(cat(1,tri1(:).RealSM), cat(1,tri1(:).SM_point));
plot(md2);
grid on;
title('Scatter Triangolo1 Soil Moisture - Soil Moisture in situ');
ylabel('Triangolo1 Soil Moisture (%)');
xlabel('Soil Moisture in situ(%)');

%creazione dello scatter plot che confronta valori di SM stimati
%con il secondo metodo del triangolo e i valori di SM reali
figure;
md3 = fitlm(cat(1,tri2(:).RealSM), cat(1,tri2(:).SSM));
plot(md3);
grid on;
title('Scatter Triangolo2 Soil Moisture - Soil Moisture in situ');
ylabel('Triangolo2 Soil Moisture (%)');
xlabel('Soil Moisture in situ(%)');