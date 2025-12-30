% Create figure
figure('Name','Row State');

% Create axes (no need for tiledlayout since it's only one plot)
ax(f) = axes; f=f+1;
hold(ax, 'on');

% Plot in-row state over time
stairs(ax, bag1.perc_time, bag1.inrow, 'LineWidth', 1.5, 'DisplayName', in_row_label);

% Set y-axis limits and label
ylim(ax, [-0.1 1.1]);
ylabel(ax, 'In-Row State');

% Plot supervisor trajectory if available
if isfield(bag1.log, 'supervisor__vehicle_status')
    plot(ax, bag1.sup_time, bag1.inrow_sup, 'LineWidth', 1.5, 'DisplayName', 'Traj In-Row');
end

% Add x-axis label and grid
xlabel(ax, 'timestamp [s]');
grid(ax, 'on');

% Show legend
legend(ax, 'show');