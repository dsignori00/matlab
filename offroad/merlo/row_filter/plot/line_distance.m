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
h = plot(bag1.lines.stamp, bag1.lines.rho(:, 1:num_lines));
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.rho(:, 1:num_lines)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("signed dist")
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show