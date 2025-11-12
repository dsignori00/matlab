% Stato previsto (es. posizione target in coordinate polari)
r_pred   = 5;       % distanza prevista
theta_pred = pi/4;  % angolo previsto (45°)

% Misure candidate (simulazione)
N_meas = 10;
r_meas = r_pred + 0.5*randn(1, N_meas);                 % range con rumore
theta_meas = theta_pred + deg2rad(30)*randn(1, N_meas); % angolo con rumore

% Parametri di gating
r_tol = 1.0;             % tolleranza sul raggio
theta_tol = deg2rad(10); % tolleranza angolare (±10°)

% Differenza angolare normalizzata in [-pi, pi]
dtheta = wrapToPi(theta_meas - theta_pred);

% Calcolo gating (condizione logica per ogni misura)
inside_gate = abs(r_meas - r_pred) <= r_tol & ...
              abs(dtheta) <= theta_tol;

% Conversione in coordinate cartesiane per il plot
[x_pred, y_pred] = pol2cart(theta_pred, r_pred);
[x_meas, y_meas] = pol2cart(theta_meas, r_meas);

% Plot
figure; hold on; axis equal;
xlabel('x'); ylabel('y');

% Stato previsto
plot(x_pred, y_pred, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 10);

% Misure candidate
plot(x_meas(~inside_gate), y_meas(~inside_gate), 'rx', 'MarkerSize', 8, 'LineWidth', 1.5);
plot(x_meas(inside_gate), y_meas(inside_gate), 'go', 'MarkerSize', 8, 'LineWidth', 1.5);

% Regione di gating (settore polare)
theta_range = linspace(theta_pred - theta_tol, theta_pred + theta_tol, 100);
r_range = [r_pred - r_tol, r_pred + r_tol];
[R, T] = meshgrid(r_range, theta_range);
[X, Y] = pol2cart(T, R);
fill([X(:,1); flipud(X(:,2))], [Y(:,1); flipud(Y(:,2))], ...
     [0.8 0.8 1], 'FaceAlpha', 0.3, 'EdgeColor','b');

% === Linee guida ===
% Assi cartesiani
xline(0,'k--','LineWidth',1); % asse verticale
yline(0,'k--','LineWidth',1); % asse orizzontale

% Semicirconferenze tratteggiate
radii = 2:1:8; % raggi a cui disegnare le semicirconferenze
theta = linspace(0, 2*pi, 200); % semicirconferenza superiore (0→180°)
for r = radii
    [xc, yc] = pol2cart(theta, r);
    plot(xc, yc, 'LineStyle','--','Color',[0.3, 0.3, 0.3],'LineWidth',0.3);
end

% Legenda
legend('Track prediction', 'Outside gating region', 'Inside gating region', 'Gating region');
grid on;

