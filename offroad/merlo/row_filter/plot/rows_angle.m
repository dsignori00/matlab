figure("Name","Row Angle")
tiledlayout(3,1);

%% cog frame

nIters = size(bag1.measures.num_lines, 1);
angles_cell = cell(nIters, 1);
stamp_cell  = cell(nIters, 1);
associated_cell = cell(nIters, 1);
for i = 1:nIters
    nRows_i = bag1.measures.num_lines(i);
    if nRows_i == 0
        continue
    end

    coeff_i = bag1.measures.coeff(i, 1:nRows_i, :);

    angles_i = atan2(coeff_i(1,:,5), coeff_i(1,:,4));
    angles_i = mod(angles_i + pi/2, pi) - pi/2;
    angles_i = angles_i(:);

    angles_cell{i} = angles_i;
    stamp_cell{i}  = repmat(bag1.measures.stamp(i), nRows_i, 1);
    associated_cell{i} = repmat(bag1.measures.associated_angle(i), nRows_i, 1);
end
meas_angle = vertcat(angles_cell{:});
meas_stamp = vertcat(stamp_cell{:});
meas_associated = logical(vertcat(associated_cell{:}));

ax(f) = nexttile; f=f+1; hold on; grid on;

% Definizione colori: verde scuro = [0 0.6 0], rosso = [1 0 0]
colors_points = zeros(length(meas_stamp), 3);

% Rosso per non associato
colors_points(~meas_associated, 1) = 1;   % R
colors_points(~meas_associated, 2) = 0;   % G
colors_points(~meas_associated, 3) = 0;   % B

% Verde scuro per associato
colors_points(meas_associated, 1) = 0;    
colors_points(meas_associated, 2) = 0.6;  % G scuro
colors_points(meas_associated, 3) = 0;    

h = scatter(meas_stamp, meas_angle * RAD2DEG, ...
            36, colors_points, 'DisplayName', "measures");

% Imposta trasparenza
h.MarkerFaceAlpha = 1.0;   
h.MarkerEdgeAlpha = 1.0;   

plot(bag1.debug.stamp,bag1.debug.rows_angle.cog, "Color",colors.matlab{1},"DisplayName","angle");
plot_patches(bag1.debug.stamp, ~bag1.debug.rows_angle.estimated, ax(f-1), patch_properties);
ylabel("cog");
title("Rows angle [deg]")
legend show

%% map frame
ax(f) = nexttile; f=f+1; hold on; grid on;
plot(bag1.debug.stamp,bag1.debug.rows_angle.map,"Color",colors.matlab{1},"DisplayName","angle");
plot_patches(bag1.debug.stamp, ~bag1.debug.rows_angle.estimated, ax(f-1), patch_properties);
ylabel("map");
legend show

%% variance
ax(f) = nexttile; f=f+1; hold on; grid on;
plot(bag1.debug.stamp, bag1.debug.rows_angle.covariance*RAD2DEG,"Color",colors.matlab{1},"DisplayName","variance");
plot_patches(bag1.debug.stamp, ~bag1.debug.rows_angle.estimated, ax(f-1), patch_properties);
ylabel("variance");
legend show