%% Generazione dati sensati nello spazio (theta, rho)
num_obs = 300;

% Media attesa (theta ~ 45°, rho ~ 10m)
mu_theta = deg2rad(45);
mu_rho = 5;

% Varianze e correlazione
sigma_theta = deg2rad(10);  % deviazione standard ~5°
sigma_rho = 1;
rho_corr = 0.0; % deviazione standard 2m

% Matrice di covarianza
cov_matrix = [sigma_theta^2, rho_corr*sigma_theta*sigma_rho;
              rho_corr*sigma_theta*sigma_rho, sigma_rho^2];

% Generazione campioni
data_samples = mvnrnd([mu_theta, mu_rho], cov_matrix, num_obs);

% Creazione tabella con tipo 'regular'
data_corr = array2table(data_samples, 'VariableNames', {'Theta','Rho'});
data_corr.type = repmat({'regular'}, num_obs, 1);

%% Centrare i dati
data_centered = data_corr;
data_centered{:, {'Theta','Rho'}} = zscore(table2array(data_corr(:, {'Theta','Rho'})));

% Estrazione dei dati numerici
mat_data = table2array(data_centered(:, {'Theta','Rho'}));

regular_data = data_centered(strcmp(data_corr.type,'regular'), :);
regular_numeric = table2array(regular_data(:, {'Theta','Rho'}));

%% Euclidean distance plot
x0 = 0; y0 = 0;
regular_distances = sqrt((regular_numeric(:,1)-x0).^2 + (regular_numeric(:,2)-y0).^2);
r = prctile(regular_distances,90);

theta_circle = linspace(0,2*pi,100);
x_circle = x0 + r*cos(theta_circle);
y_circle = y0 + r*sin(theta_circle);

inside_regular = regular_distances <= r;
outside_regular = ~inside_regular;

figure('Name','Euclidean')
hold on
scatter(regular_numeric(inside_regular,1),regular_numeric(inside_regular,2),20,'blue','filled','LineWidth',2)
scatter(regular_numeric(outside_regular,1),regular_numeric(outside_regular,2),20,'red','filled','LineWidth',2)
plot(x_circle,y_circle,'--k','LineWidth',1.5)
xlabel('\theta [rad]')
ylabel('\rho [m]')
title('Euclidean Distance')
axis equal
grid on
legend('Correct','Incorrect','Location','northwest')

%% Mahalanobis distance plot
S = cov(mat_data);
regular_distances_m = mahal(regular_numeric, mat_data);
r_prime = prctile(regular_distances_m, 90);  % soglia percentilica

theta_circle = linspace(0,2*pi,100);
circle = [cos(theta_circle); sin(theta_circle)];

% Autovettori e autovalori
[eig_vec, eig_val] = eig(S);

% Trasformazione corretta per l'ellisse
transform = eig_vec * sqrt(eig_val) * sqrt(r_prime);
ellipse = transform * circle;

% Centrare sull'origine (o media)
mu = mean(mat_data,1)'; % vettore colonna
ellipse = ellipse + mu;

% Plot
inside_regular_m = regular_distances_m <= r_prime;
outside_regular_m = ~inside_regular_m;

figure('Name','Mahalanobis')
hold on
scatter(regular_numeric(inside_regular_m,1),regular_numeric(inside_regular_m,2),20,'blue','filled','LineWidth',2)
scatter(regular_numeric(outside_regular_m,1),regular_numeric(outside_regular_m,2),20,'red','filled','LineWidth',2)
plot(ellipse(1,:),ellipse(2,:),'--k','LineWidth',1.5)
xlabel('\theta [rad]')
ylabel('\rho [m]')
title('Mahalanobis Distance')
axis equal
grid on
legend('Valid','Discarded','Location','northwest')


%% Mahalanobis vs Euclidean plot
figure('Name','Mahalanobis vs Euclidean')
tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');

% Euclidean
nexttile
hold on
scatter(regular_numeric(inside_regular,1),regular_numeric(inside_regular,2),20,'blue','filled','LineWidth',2)
scatter(regular_numeric(outside_regular,1),regular_numeric(outside_regular,2),20,'red','filled','LineWidth',2)
plot(x_circle,y_circle,'--k','LineWidth',1.5)
xlabel('\theta [rad]')
ylabel('\rho [m]')
title('Euclidean Distance')
axis equal
grid on
xlim([-3,3])
ylim([-3,3])

% Mahalanobis
nexttile
hold on
scatter(regular_numeric(inside_regular_m,1),regular_numeric(inside_regular_m,2),20,'blue','filled','LineWidth',2)
scatter(regular_numeric(outside_regular_m,1),regular_numeric(outside_regular_m,2),20,'red','filled','LineWidth',2)
plot(ellipse(:,1),ellipse(:,2),'--k','LineWidth',1.5)
xlabel('\theta [rad]')
ylabel('\rho [m]')
title('Mahalanobis Distance')
axis equal
grid on
xlim([-3,3])
ylim([-3,3])

%% Ellisse di confidenza (theta,rho)
k = 5.991; % soglia chi-quadro 95% per 2 dof
circle = [cos(theta_circle); sin(theta_circle)];
transform = eig_vec * sqrt(eig_val) * sqrt(k);
ellipse_points = transform * circle;
ellipse_points(1,:) = ellipse_points(1,:) + 0; % centro (0,0)
ellipse_points(2,:) = ellipse_points(2,:) + 0;

figure;
hold on
plot(ellipse_points(1,:),ellipse_points(2,:),'b-','LineWidth',2)
plot(0,0,'ro','MarkerFaceColor','r')
xlabel('\theta [rad]')
ylabel('\rho [m]')
title('Ellisse basata sulla distanza di Mahalanobis')
axis equal
grid on

%% Distanza di Mahalanobis 3D
% Calcolo la Mahalanobis distance per tutti i punti
mahal_distances = mahal(mat_data, mat_data); % distanza Mahalanobis

% Plot 3D
figure('Name','Mahalanobis Distance 3D')
scatter3(regular_numeric(:,1), regular_numeric(:,2), mahal_distances, 40, mahal_distances, 'filled');
colormap(jet);
colorbar;
xlabel('\theta [rad]');
ylabel('\rho [m]');
zlabel('Mahalanobis Distance');
title('Mahalanobis Distance per ciascun punto nello spazio (\theta, \rho)');
grid on;
view(45,30);

