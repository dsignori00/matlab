figure('Name','Line distance')
tiledlayout(2,1)

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
plot(bag1.perc_time, bag1.state.dist_left_row, 'DisplayName','L');
plot(bag1.perc_time, bag1.state.dist_right_row, 'DisplayName','R');
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
ylabel("distance [m]")
legend show

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);
line_colors = color_tints_and_shades(colors.matlab{1}, double(num_lines), 0.7);

if log_row_eq
    for i = 1:num_lines
        % Definizione colori: verde scuro = [0 0.6 0], rosso = [1 0 0]
        colors_points = zeros(length(bag1.measures.associated), 3);
        associated = logical(bag1.measures.associated(:, i));

        % Rosso per non associato
        colors_points(~associated, 1) = 1;   % R
        colors_points(~associated, 2) = 0;   % G
        colors_points(~associated, 3) = 0;   % B

        % Verde scuro per associato
        colors_points(associated, 1) = 0;    
        colors_points(associated, 2) = 0.6;  % G scuro
        colors_points(associated, 3) = 0;    

        h = scatter(bag1.measures.stamp, bag1.measures.rho(:, i), ...
                    36, colors_points);

        % Imposta trasparenza
        h.MarkerFaceAlpha = 1.0;   
        h.MarkerEdgeAlpha = 1.0;   
    end
end

h = gobjects(num_lines, 1);
for i = 1:num_lines
    h(i) = plot(bag1.lines.stamp, bag1.lines.rho(:, i), 'Color', line_colors{i});
end

plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("signed dist")
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
lgd = legend(h, labels, 'Location','northeast');