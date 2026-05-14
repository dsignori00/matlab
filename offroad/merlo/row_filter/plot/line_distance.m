figure('Name','Line distance', 'NumberTitle','off');
tiledlayout(2,1)

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
plot(bag1.state.stamp, bag1.state.dist_left_row, 'DisplayName',bag1.log_name + 'L');
plot(bag1.state.stamp, bag1.state.dist_right_row, 'DisplayName',bag1.log_name + 'R');
if compare
    plot(bag2.state.stamp, bag2.state.dist_left_row, 'DisplayName',bag2.log_name + 'L');
    plot(bag2.state.stamp, bag2.state.dist_right_row, 'DisplayName',bag2.log_name + 'R');
end
plot_patches(bag1.state.stamp, ~bag1.state.in_row, ax(f-1), patch_properties);
ylabel("distance [m]")
legend show

%% sigend dist
ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_lines);
line_colors = color_tints_and_shades(colors.matlab{1}, double(num_lines), 0.7);

for i = 1:num_lines
        % Definizione colori: verde scuro = [0 0.6 0], rosso = [1 0 0]
        colors_points = zeros(length(bag1.measures.associated_line), 3);
        associated_line = logical(bag1.measures.associated_line(:, i));

        % Rosso per non associato
        colors_points(~associated_line, 1) = 1;   % R
        colors_points(~associated_line, 2) = 0;   % G
        colors_points(~associated_line, 3) = 0;   % B

        % Verde scuro per associato
        colors_points(associated_line, 1) = 0;    
        colors_points(associated_line, 2) = 0.6;  % G scuro
        colors_points(associated_line, 3) = 0;    

        h = scatter(bag1.measures.stamp, bag1.measures.rho(:, i), ...
                    36, colors_points);

        % Imposta trasparenza
        h.MarkerFaceAlpha = 1.0;   
        h.MarkerEdgeAlpha = 1.0;   
end

if compare
    num_lines2 = max(bag2.lines.num_lines);
    for i = 1:num_lines2
        % Definizione colori: verde scuro = [0 0.6 0], rosso = [1 0 0]
        colors_points = zeros(length(bag2.measures.associated_line), 3);
        associated_line = logical(bag2.measures.associated_line(:, i));

        % Rosso per non associato
        colors_points(~associated_line, 1) = 1;   % R
        colors_points(~associated_line, 2) = 0;   % G
        colors_points(~associated_line, 3) = 0;   % B

        % Verde scuro per associato
        colors_points(associated_line, 1) = 0;    
        colors_points(associated_line, 2) = 0.6;  % G scuro
        colors_points(associated_line, 3) = 0;    

        h = scatter(bag2.measures.stamp, bag2.measures.rho(:, i), ...
                    36, colors_points);

        % Imposta trasparenza
        h.MarkerFaceAlpha = 1.0;   
        h.MarkerEdgeAlpha = 1.0;   
    end
end

h = gobjects(num_lines, 1);
for i = 1:num_lines
    if compare; k = 1; else; k = i; end
    h(i) = plot(bag1.lines.stamp, bag1.lines.rho(:, i), 'Color', colors.matlab{k}, 'DisplayName', "Bag1");
end

if compare
    h2 = gobjects(num_lines2, 1);
    for i = 1:num_lines2
        h2(i) = plot(bag2.lines.stamp, bag2.lines.rho(:, i), 'Color', colors.matlab{2},'DisplayName', "Bag2");
    end
    legend ([h(1); h2(1)],'Location','northeast');
end

plot_patches(bag1.state.stamp, ~bag1.state.in_row, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("signed dist")