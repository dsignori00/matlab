figure('Name','Line Equations')
tiledlayout(2,1)
ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);
line_colors = color_tints_and_shades(colors.matlab{1}, double(num_lines), 0.7);

if (OUTPUT_LINE_FORM == LINEFORM.EXPLICIT)
    p1_label = "m [-]";
elseif (OUTPUT_LINE_FORM == LINEFORM.NORMAL)
    p1_label = " alpha [deg]";
else
    p1_label = " ";
end

%% p1

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

        h = scatter(bag1.measures.stamp, bag1.measures.p1(:, i) * RAD2DEG, ...
                    36, colors_points);

        % Imposta trasparenza
        h.MarkerFaceAlpha = 1.0;   
        h.MarkerEdgeAlpha = 1.0;   
    end
end

h = gobjects(num_lines, 1);
for i = 1:num_lines
    h(i) = plot(bag1.lines.stamp, bag1.lines.p1(:, i) * RAD2DEG, 'Color', line_colors{i});
end

plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
ylabel(p1_label)
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show

%% p2

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);
if (OUTPUT_LINE_FORM == LINEFORM.EXPLICIT)
    p2_label = "Q [-]";
elseif (OUTPUT_LINE_FORM == LINEFORM.NORMAL)
    p2_label = " ort dist [m]";
else
    p2_label = " ";
end

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

        h = scatter(bag1.measures.stamp, bag1.measures.p2(:, i), ...
                    36, colors_points);

        % Imposta trasparenza
        h.MarkerFaceAlpha = 1.0;   
        h.MarkerEdgeAlpha = 1.0;   
    end
end

h = gobjects(num_lines, 1);
for i = 1:num_lines
    h(i) = plot(bag1.lines.stamp, bag1.lines.p2(:, i), 'Color', line_colors{i});
end

plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel(p2_label)
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show