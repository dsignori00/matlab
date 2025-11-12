% Dati di input
% v_fl = log.vehicle_fbk_eva__v_fl;      % Segnale da filtrare
v_fl = (log.vehicle_fbk_eva__v_fl+log.vehicle_fbk_eva__v_fr)/2;      % Segnale da filtrare
time = log.vehicle_fbk_eva__stamp__tot; % Asse dei tempi

% Parametri del filtro
f_c = 3;                              % Frequenza di taglio in Hz
omega_c = 2 * pi * f_c;                % Pulsazione di taglio in rad/s

% Creazione del filtro passa-basso
numerator = omega_c^2*[1 0];                   % Numeratore del filtro
% denominator = [1 omega_c];             % Denominatore del filtro
% numerator = omega_c^2;                 % Numeratore del filtro
denominator = [1 2*omega_c omega_c^2]; % Denominatore del filtro
sys = tf(numerator, denominator);      % Funzione di trasferimento del filtro

% Simulazione della risposta al segnale
dt = mean(diff(time));                 % Passo temporale medio
t_sim = 0:dt:max(time);                % Asse temporale uniforme per lsim
v_fl_interp = interp1(time, v_fl, t_sim, 'linear', 'extrap'); % Interpolazione del segnale

% Filtraggio del segnale
v_fl_filtered = lsim(sys, v_fl_interp, t_sim);

% Plot dei risultati
figure;
% subplot(2,1,1);
plot(time, v_fl, 'b', 'DisplayName', 'Segnale originale'); hold on;
plot(t_sim, v_fl_filtered, 'r', 'DisplayName', 'Segnale filtrato');
xlabel('Tempo (s)');
ylabel('Velocità (m/s)');
title('Filtraggio passa-basso');
legend('show');
grid on


% acc=gradient(v_fl_filtered*0.3106,t_sim);
acc=v_fl_filtered*0.3106;
figure;
plot(t_sim,acc)
grid on;
hold on;
plot(log.estimation__bag_timestamp,log.estimation__ax)