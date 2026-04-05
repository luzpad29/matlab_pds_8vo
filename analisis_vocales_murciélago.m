%% SEGMENTACIÓN DE VOCALES Y ANÁLISIS ACÚSTICO
% Proyecto: Análisis de la palabra "MURCIÉLAGO"
% Objetivo: Identificar las 5 vocales (U, I, E, A, O), calcular su duración, 
% energía RMS, frecuencia fundamental y analizar sus características espectrales
% Autor: luzpad29
% Fecha: 2026-04-05

clear all; close all; clc;

%% 1. CARGAR Y EXPLORAR EL AUDIO
fprintf('\n========== ANÁLISIS ACÚSTICO DE VOCALES ==========\n');

% Seleccionar archivo de audio
fprintf('\nArchivos disponibles:\n');
fprintf('1. murcielago_hombre.wav\n');
fprintf('2. murcielago_mujer.wav\n');
fprintf('3. murcielago_adulto_mayor.wav\n');
opcion = input('Selecciona opción (1-3): ');

archivos = {'murcielago_hombre.wav', 'murcielago_mujer.wav', 'murcielago_adulto_mayor.wav'};
archivo_audio = archivos{opcion};

% Cargar audio
y = audioread(archivo_audio);
Fs = 44100; % Frecuencia de muestreo de ejemplo
info = audioinfo(archivo_audio);

% Información del audio
fprintf('\n--- INFORMACIÓN DEL AUDIO ---\n');
fprintf('Archivo: %s\n', archivo_audio);
fprintf('Frecuencia de muestreo (Fs): %d Hz\n', Fs);
fprintf('Duración total: %.2f segundos\n', info.Duration);
fprintf('Canales: %d\n', info.NumChannels);
fprintf('Bits por muestra: %d\n', info.BitsPerSample);

% Convertir a mono si es estéreo
if size(y, 2) > 1
    y = mean(y, 2);
end

% Reproducir audio
fprintf('\nReproduciendo audio...\n');
sound(y, Fs);
pause(info.Duration + 1);

%% 2. VISUALIZACIÓN DE LA SEÑAL COMPLETA
tiempo = (0:length(y)-1) / Fs;

figure('Name', 'Señal de Audio Completa', 'NumberTitle', 'off');
plot(tiempo, y, 'b', 'LineWidth', 1.5);
xlabel('Tiempo (s)', 'FontSize', 11);
ylabel('Amplitud', 'FontSize', 11);
title(['Onda de Audio Completa: ' archivo_audio], 'FontSize', 12, 'FontWeight', 'bold');
grid on;
xlim([0 max(tiempo)]);

fprintf('\nObserva la gráfica y anota los tiempos de inicio y fin de cada vocal.\n');
fprintf('MURCIÉLAGO contiene: U, I, E, A, O\n');

%% 3. SEGMENTACIÓN MANUAL DE VOCALES
fprintf('\n--- SEGMENTACIÓN DE VOCALES ---\n');
fprintf('Ingresa los tiempos de inicio y fin (en segundos) para cada vocal.\n');

vocales = {'U', 'I', 'E', 'A', 'O'};
tiempos_vocales = {};
segmentos = {};
indices_vocales = {};

for i = 1:5
    fprintf('\n--- VOCAL: %s ---\n', vocales{i});
    t_inicio = input(sprintf('Tiempo de inicio para %s (s): ', vocales{i}));
    t_fin = input(sprintf('Tiempo de fin para %s (s): ', vocales{i}));
    
    % Convertir tiempo a índices
    idx_inicio = round(t_inicio * Fs) + 1;
    idx_fin = round(t_fin * Fs);
    
    % Validar índices
    idx_inicio = max(1, idx_inicio);
    idx_fin = min(length(y), idx_fin);
    
    tiempos_vocales{i} = [t_inicio, t_fin];
    segmentos{i} = y(idx_inicio:idx_fin);
    indices_vocales{i} = [idx_inicio, idx_fin];
end

%% 4. ANÁLISIS EN DOMINIO DEL TIEMPO
fprintf('\n========== ANÁLISIS EN DOMINIO DEL TIEMPO ==========\n');

resultados = table();

for i = 1:5
    % Duración
    duracion = length(segmentos{i}) / Fs;
    
    % Energía RMS (Root Mean Square)
rms_energia = sqrt(mean(segmentos{i}.^2));
    
    % Amplitud pico
    amplitud_pico = max(abs(segmentos{i}));
    
    fprintf('\n--- VOCAL %s ---\n', vocales{i});
    fprintf('Duración: %.4f s\n', duracion);
    fprintf('Energía RMS: %.6f\n', rms_energia);
    fprintf('Amplitud pico: %.6f\n', amplitud_pico);
    
    resultados = [resultados; table(vocales{i}, duracion, rms_energia, amplitud_pico, ...
        'VariableNames', {'Vocal', 'Duracion_s', 'Energia_RMS', 'Amplitud_Pico'})];
end

%% 5. ANÁLISIS EN DOMINIO DE LA FRECUENCIA - AUTOCORRELACIÓN
fprintf('\n========== ANÁLISIS DE FRECUENCIA FUNDAMENTAL (TONO) ==========\n');

figure('Name', 'Análisis de Frecuencia Fundamental', 'NumberTitle', 'off');

for i = 1:5
    % Extraer segmento corto para autocorrelación (primeros 50ms)
    num_muestras = round(0.05 * Fs); % 50 ms
    num_muestras = min(num_muestras, length(segmentos{i}));
    segmento_corto = segmentos{i}(1:num_muestras);
    
    % Aplicar ventana de Hamming
    segmento_corto = segmento_corto .* hamming(length(segmento_corto));
    
    % Calcular autocorrelación
    [acf, lag] = xcorr(segmento_corto, 'coeff');
    
    % Usar solo la mitad positiva
    acf = acf(length(segmento_corto):end);
    lag_ms = (0:length(acf)-1) / Fs * 1000; % Convertir a milisegundos
    
    % Encontrar el pico más significativo después del lag 0
    umbral_lag = round(Fs / 500); % Mínimo 500 Hz de frecuencia fundamental
    [picos, locs] = findpeaks(acf(umbral_lag:end), 'SortStr', 'descend', 'NPeaks', 1);
    
    if ~isempty(locs)
        lag_fundamental = locs(1) + umbral_lag - 1;
        frecuencia_fundamental = Fs / lag_fundamental;
    else
        frecuencia_fundamental = NaN;
    end
    
    fprintf('Vocal %s: Frecuencia fundamental ≈ %.1f Hz\n', vocales{i}, frecuencia_fundamental);
    
    % Graficar autocorrelación
    subplot(2, 3, i);
    plot(lag_ms(1:round(length(lag_ms)/2)), acf(1:round(length(acf)/2)), 'b', 'LineWidth', 1.5);
    xlabel('Lag (ms)', 'FontSize', 9);
    ylabel('Autocorrelación', 'FontSize', 9);
    title(['Vocal: ' vocales{i}], 'FontSize', 10, 'FontWeight', 'bold');
    grid on;
xlim([0 20]);
end

%% 6. ESPECTROGRAMAS DE VOCALES
fprintf('\n========== GENERANDO ESPECTROGRAMAS ==========\n');

figure('Name', 'Espectrogramas de Vocales', 'NumberTitle', 'off');

parámetros_espectrograma = struct();

for i = 1:5
    subplot(2, 3, i);
    
    % Parámetros del espectrograma
    ventana = hamming(round(Fs * 0.025)); % Ventana de 25ms
    solapamiento = round(0.015 * Fs); % 15ms de solapamiento
    nfft = 2^nextpow2(Fs * 0.025); % FFT size
    
    % Generar espectrograma
    spectrogram(segmentos{i}, ventana, solapamiento, nfft, Fs, 'yaxis');
    
    title(['Espectrograma - Vocal: ' vocales{i}], 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Frecuencia (Hz)', 'FontSize', 9);
    xlabel('Tiempo (s)', 'FontSize', 9);
    
    % Establecer límites de frecuencia relevantes
    ylim([0 4000]);
    
    % Agregar colorbarra
    c = colorbar;
    c.Label.String = 'Potencia (dB)';
    c.Label.FontSize = 9;
end

%% 7. ANÁLISIS DE FORMANTES
fprintf('\n========== ANÁLISIS DE FORMANTES ==========\n');

figure('Name', 'Espectro de Potencia y Formantes', 'NumberTitle', 'off');

for i = 1:5
    subplot(2, 3, i);
    
    % Extraer segmento con ventana
    ventana = hamming(length(segmentos{i}));
    segmento_ventaneado = segmentos{i} .* ventana;
    
    % Calcular FFT
    nfft = 2^nextpow2(length(segmento_ventaneado));
    espectro = abs(fft(segmento_ventaneado, nfft));
    frecuencias = (0:nfft/2-1) * Fs / nfft;
    
    % Normalizar
    espectro_db = 20 * log10(espectro(1:nfft/2) + eps);
    
    % Graficar espectro
    plot(frecuencias, espectro_db, 'b', 'LineWidth', 1.5);
    xlabel('Frecuencia (Hz)', 'FontSize', 9);
    ylabel('Magnitud (dB)', 'FontSize', 9);
    title(['Espectro - Vocal: ' vocales{i}], 'FontSize', 10, 'FontWeight', 'bold');
    grid on;
xlim([0 4000]);
    
    % Identificar picos (formantes aproximados)
    [picos, locs] = findpeaks(espectro_db, 'MinPeakDistance', round(Fs/1000), 'NPeaks', 3);
    if ~isempty(locs)
        formantes = frecuencias(locs(1:min(3, length(locs))));
        hold on;
        plot(formantes, picos(1:length(formantes)), 'ro', 'MarkerSize', 6, 'LineWidth', 2);
        fprintf('Vocal %s - Formantes aproximados: %.0f, %.0f Hz\n', vocales{i}, formantes(1), ...
            length(formantes) > 1 ? formantes(2) : 0);
    end
end

%% 8. TABLA RESUMEN DE RESULTADOS
fprintf('\n========== RESUMEN DE RESULTADOS ==========\n');
disp(resultados);

%% 9. EXPLICACIÓN: ANÁLISIS ESPECTROGRAMA vs CÓCLEA
fprintf('\n========== ANÁLISIS: ESPECTROGRAMA Y CÓCLEA ==========\n');
fprintf(['\n--- ANALOGÍA ENTRE ESPECTROGRAMA Y LA CÓCLEA ---\n\n', ...
    '1. MEMBRANA BASILAR (Biología):\n', ...
    '   - La cóclea es un órgano del oído interno en forma de espiral.\n', ...
    '   - Contiene la membrana basilar, que vibra en respuesta a ondas sonoras.\n', ...
    '   - Diferentes frecuencias causan vibraciones en diferentes puntos:\n', ...
    '     * Frecuencias ALTAS: Vibración cerca de la base (entrada)\n', ...
    '     * Frecuencias BAJAS: Vibración cerca del ápice (final)\n', ...
    '   - Las células ciliadas convierten estas vibraciones en impulsos nerviosos.\n\n', ...
    '2. ESPECTROGRAMA (Procesamiento de Señales):\n', ...
    '   - Descompone una señal de audio en sus componentes de frecuencia.\n', ...
    '   - Muestra TIEMPO vs FRECUENCIA vs POTENCIA (colores).\n', ...
    '   - Utiliza transformadas de Fourier de corta duración (STFT).\n', ...
    '   - Separa frecuencias similares a como la membrana basilar.\n\n', ...
    '3. FORMANTES Y PERCEPCIÓN DE VOCALES:\n', ...
    '   - Los FORMANTES son resonancias del tracto vocal (garganta, boca, labios).\n', ...
    '   - Cada vocal tiene un patrón característico de formantes:\n', ...
    '     * Vocal U: F1 ≈ 300-400 Hz, F2 ≈ 700-900 Hz\n', ...
    '     * Vocal I: F1 ≈ 200-300 Hz, F2 ≈ 2000-2500 Hz\n', ...
    '     * Vocal E: F1 ≈ 400-600 Hz, F2 ≈ 1500-2000 Hz\n', ...
    '     * Vocal A: F1 ≈ 600-800 Hz, F2 ≈ 1000-1500 Hz\n', ...
    '     * Vocal O: F1 ≈ 500-700 Hz, F2 ≈ 800-1000 Hz\n\n', ...
    '4. IMPLANTES COCLEARES:\n', ...
    '   - Son dispositivos que restauran audición en personas sordas.\n', ...
    '   - Funcionan de manera similar al análisis espectrograma:\n', ...
    '     * Micrófono: Captura el sonido.\n', ...
    '     * Procesador: Descompone el sonido en bandas de frecuencia.\n', ...
    '     * Electrodos: Estimulan diferentes puntos de la cóclea según frecuencia.\n', ...
    '   - Los electrodos bajos estimulan frecuencias bajas (base).\n', ...
    '   - Los electrodos altos estimulan frecuencias altas (ápice).\n', ...
    '   - Replican el procesamiento natural de la membrana basilar.\n\n', ...
    '5. RELACIÓN ESPECTROGRAMA-CÓCLEA-IMPLANTES:\n', ...
    '   - El espectrograma muestra lo que la cóclea hace naturalmente.\n', ...
    '   - Los implantes cocleares utilizan este principio:\n', ...
    '     * Analizan el espectro (como el espectrograma).\n', ...
    '     * Mapean frecuencias a posiciones de electrodos (como la membrana basilar).\n', ...
    '   - Al reconstruir patrones de formantes, permiten reconocer vocales.\n']);
fprintf('\n========== FIN DEL ANÁLISIS ==========\n\n');