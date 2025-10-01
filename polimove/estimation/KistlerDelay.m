% Caricamento dei dati
vx1 = log.estimation.vx;
vx2 = log.estimation.vx_vehicle_speed_report__v(:,1);
time = log.estimation.stamp__tot;

% Definizione del range di sfasamenti temporali possibili
idx_shift = -20:20; % Adatta il range se necessario
errors = zeros(size(idx_shift));

valid_idx = abs(log.estimation.ax(21:end-21))>0;

% Minimizzazione dell'errore quadratico medio tra vx1(t) e vx2(t+dt)
for i = 1:length(idx_shift)

    errors(i) = mean((vx1(21:end-21) - vx2((21:end-21)+idx_shift(i))).^2.*double(valid_idx));

end

% Trova il dt ottimale
[~, min_idx] = min(errors);
dt_optimal = idx_shift(min_idx);

% Stampa il risultato
fprintf('Lo sfasamento temporale ottimale dt è: %.6f indici\n', dt_optimal);

figure;
plot(time(21:end-21),vx1(21:end-21).*double(valid_idx),'DisplayName','est');
hold on;grid on;
for n=-2:2
    plot(time(21:end-21),vx2((21:end-21)+n),'DisplayName',num2str(n));
end
legend show