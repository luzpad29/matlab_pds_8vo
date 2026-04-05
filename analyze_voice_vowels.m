% Script para análisis acústico y comparación de voces en MATLAB
% Este script realiza tres ejercicios: segmentación de vocales, análisis acústico, y comparación de voces entre géneros.
% Incluye visualizaciones y explicaciones educativas sobre la cóclea, formantes y aplicaciones en patologías de la voz.

% Definición de funciones
yclea = 'Estructura del oído interno que convierte las ondas sonoras en señales eléctricas.';
formantes = 'Las formantes son frecuencias resonantes que caracterizan las vocales.';
pathologias = 'Algunas patologías de la voz incluyen disartria y afonía.';

% Ejercicio 1: Segmentación de vocales
%-------------------------------

% Cargar el archivo de audio
[audio, fs] = audioread('audio_sample.wav');

% Visualización de la señal de audio
time = (0:length(audio)-1)/fs;
figure;
plot(time, audio);
title('Señal de audio original');
xlabel('Tiempo (s)');
ylabel('Amplitud');

% Segmentación de vocales usando un umbral
e = energy(audio);
vocales = segment_vocales(audio, fs, e);

% Visualizar la segmentaciónigure;
plot(vocales);
title('Segmentación de Vocales');

% Ejercicio 2: Análisis acústico
%-----------------------------

% Calcular los formantes
[formantes_freq] = calcular_formantes(audio, fs);

% Visualización de los formantes
figure;
bar(formantes_freq);
title('Frecuencias de Formantes');
xlabel('Formantes');
ylabel('Frecuencia (Hz)');

% Ejercicio 3: Comparación de voces entre géneros
%----------------------------------------------------

% Cargar otro archivo de audio (voz femenina)
[audio_fem, fs_fem] = audioread('audio_fem.wav');

% Calcular características acústicas (media, varianza)
[carac_masculino] = caracteristicas_acusticas(audio);
[carac_femenino] = caracteristicas_acusticas(audio_fem);

% Comparar características de género
figure;
bar([carac_masculino; carac_femenino]);
title('Comparación de Características Acústicas');
legend('Masculino', 'Femenino');

% Explicaciones educativas
fprintf('Coclea: %s\n', yclea);
fprintf('Formantes: %s\n', formantes);
fprintf('Patologías: %s\n', pathologias);
