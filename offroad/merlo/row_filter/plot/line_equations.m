figure('Name','Line Equations')
tiledlayout(2,1)
ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);

if (OUTPUT_LINE_FORM == LINEFORM.EXPLICIT)
    p1_label = "m [-]";
elseif (OUTPUT_LINE_FORM == LINEFORM.NORMAL)
    p1_label = " alpha [deg]";
else
    p1_label = " ";
end

h = plot(bag1.lines.stamp, bag1.lines.p1(:, 1:num_lines) * RAD2DEG);
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.p1(:, 1:num_lines) * RAD2DEG); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
ylabel(p1_label)
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);
if (OUTPUT_LINE_FORM == LINEFORM.EXPLICIT)
    p2_label = "Q [-]";
elseif (OUTPUT_LINE_FORM == LINEFORM.NORMAL)
    p2_label = " ort dist [m]";
else
    p2_label = " ";
end
h = plot(bag1.lines.stamp, bag1.lines.p2(:, 1:num_lines));
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.p2(:, 1:num_lines)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel(p2_label)
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show