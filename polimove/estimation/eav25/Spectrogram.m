% Compute spectrogram

timeColumn = seconds(log.g1pro__imu0.header__stamp__tot);
imuMagnitude = sqrt(log.g1pro__imu0.ax.^2 + log.g1pro__imu0.ay.^2 + log.g1pro__imu0.az.^2);


imuTimetable = timetable(timeColumn, imuMagnitude, 'VariableNames', {'Magnitude'});

% Parametri dello spettrogramma
frequencyLimits = [0.1, 200]; % Limiti di frequenza in Hz
overlapPercent = 20; % Sovrapposizione in percentuale

% Calcola lo spettrogramma
[P, F, T] = pspectrum(imuTimetable, ...
    'spectrogram', ...
    'FrequencyLimits', frequencyLimits, ...
    'OverlapPercent', overlapPercent,'TimeResolution',5);

% Converti P in scala logaritmica (dB) per una migliore visualizzazione
P_dB = 10 * log10(P);

% Visualizza lo spettrogramma
figure;
tiledlayout(2,1,'Padding','tight');
ax(1)=nexttile;
imagesc(seconds(T), F, P_dB); % T sull'asse x, F sull'asse y, P_dB come colori
axis xy; % Inverte gli assi per visualizzare frequenze crescenti verso l'alto
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
title('Spectrogram');
colorbar; % Aggiunge una barra dei colori per indicare la potenza
colormap jet; % Imposta la mappa dei colori a "jet"

ax(2)=nexttile;
plot(log.vehicle_fbk.bag_stamp,log.vehicle_fbk.engine_rpm,'DisplayName','Engine RPM');

linkaxes(ax,'x');


%% Vectornav

timeColumn = seconds(log.vectornav__raw__common.header__stamp__tot);
imuMagnitude = sqrt(log.vectornav__raw__common.imu_accel__x.^2 + log.vectornav__raw__common.imu_accel__y.^2 + log.vectornav__raw__common.imu_accel__z.^2);


imuTimetable = timetable(timeColumn, imuMagnitude, 'VariableNames', {'Magnitude'});

% Parametri dello spettrogramma
frequencyLimits = [0.1, 100]; % Limiti di frequenza in Hz
overlapPercent = 20; % Sovrapposizione in percentuale

% Calcola lo spettrogramma
[P, F, T] = pspectrum(imuTimetable, ...
    'spectrogram', ...
    'FrequencyLimits', frequencyLimits, ...
    'OverlapPercent', overlapPercent,'TimeResolution',5);

% Converti P in scala logaritmica (dB) per una migliore visualizzazione
P_dB = 10 * log10(P);

% Visualizza lo spettrogramma
figure;
tiledlayout(2,1,'Padding','tight');
ax(1)=nexttile;
imagesc(seconds(T), F, P_dB); % T sull'asse x, F sull'asse y, P_dB come colori
axis xy; % Inverte gli assi per visualizzare frequenze crescenti verso l'alto
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
title('Spectrogram');
colorbar; % Aggiunge una barra dei colori per indicare la potenza
colormap jet; % Imposta la mappa dei colori a "jet"

ax(2)=nexttile;
plot(log.vehicle_fbk.bag_stamp,log.vehicle_fbk.engine_rpm,'DisplayName','Engine RPM');

linkaxes(ax,'x');
