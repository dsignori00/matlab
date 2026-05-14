figure('Name','Angle Estimates', 'NumberTitle','off');
tiledlayout(2,1)

num_lines = max(bag1.lines.num_lines);
line_colors = color_tints_and_shades(colors.matlab{1}, double(num_lines), 0.7);

if (OUTPUT_LINE_FORM == LINEFORM.EXPLICIT)
    p1_label = "m [-]";
elseif (OUTPUT_LINE_FORM == LINEFORM.NORMAL)
    p1_label = " alpha [deg]";
else
    p1_label = " ";
end

% wrapping
for i = 1:num_lines
    lines1.p1(:, i) = unwrap_angle_pi_half(bag1.lines.p1(:, i), bag1.debug.rows_angle.cog * DEG2RAD);
    lines1.measures.p1(:, i) = unwrap_angle_pi_half(bag1.measures.p1(:, i), bag1.debug.rows_angle.cog * DEG2RAD);
    if compare
        lines2.p1(:, i) = unwrap_angle_pi_half(bag2.lines.p1(:, i), bag2.debug.rows_angle.cog * DEG2RAD);
        lines2.measures.p1(:, i) = unwrap_angle_pi_half(bag2.measures.p1(:, i), bag2.debug.rows_angle.cog * DEG2RAD);
    end
end

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
for i = 1:num_lines
    scatter(bag1.measures.stamp, lines1.measures.p1(:, i) * RAD2DEG, 36, 'MarkerEdgeColor', colors.matlab{2}, "HandleVisibility", "off");
    plot(bag1.lines.stamp, lines1.p1(:, i) * RAD2DEG, 'Color', colors.matlab{1}, "HandleVisibility", "off");
end
plot(NaN, NaN, 'Color', colors.matlab{1}, 'DisplayName', "Estimated Row");
plot(NaN, NaN, 'Color', colors.matlab{2}, 'DisplayName', "Row Measures");
plot(bag1.debug.stamp, bag1.debug.rows_angle.cog, 'k', 'DisplayName', "COG Row Angle");

if compare
    for i = 1:num_lines
        plot(bag2.lines.stamp, lines2.p1(:, i) * RAD2DEG, 'Color', colors.matlab{3}, "HandleVisibility", "off");
        scatter(bag2.measures.stamp, lines2.measures.p1(:, i) * RAD2DEG, 36, 'MarkerEdgeColor', colors.matlab{4}, "HandleVisibility", "off");
    end
    plot(NaN, NaN, 'Color', colors.matlab{3}, 'DisplayName', "Estimated Row - Bag 2");
    plot(NaN, NaN, 'Color', colors.matlab{4}, 'DisplayName', "Row Measures - Bag 2");
    plot(bag2.debug.stamp, bag2.debug.rows_angle.cog, 'k', 'DisplayName', "COG Row Angle - Bag 2");
end
legend('Location', 'best');
ylabel("Row Angle [deg]");
title("Row Angle Estimates");

% differeces
ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
for i = 1:num_lines
    % scatter(bag1.measures.stamp, (lines1.measures.p1(:, i) * RAD2DEG - bag1.debug.rows_angle.cog), 36, 'MarkerEdgeColor', colors.matlab{2}, "HandleVisibility", "off");
    plot(bag1.lines.stamp, lines1.p1(:, i) * RAD2DEG - bag1.debug.rows_angle.cog, 'Color', colors.matlab{1}, "HandleVisibility", "off");
end
yline(0, 'k--', "HandleVisibility", "off");
plot(NaN, NaN, 'Color', colors.matlab{1}, 'DisplayName', "Estimated Row");
plot(NaN, NaN, 'Color', colors.matlab{2}, 'DisplayName', "Row Measures");
if compare
    for i = 1:num_lines
        % scatter(bag2.measures.stamp, lines2.measures.p1(:, i) * RAD2DEG - bag2.debug.rows_angle.cog, 36, 'MarkerEdgeColor', colors.matlab{4}, "HandleVisibility", "off");
        plot(bag2.lines.stamp, lines2.p1(:, i) * RAD2DEG - bag2.debug.rows_angle.cog, 'Color', colors.matlab{3}, "HandleVisibility", "off");
    end
    plot(NaN, NaN, 'Color', colors.matlab{3}, 'DisplayName', "Estimated Row - Bag 2");
    plot(NaN, NaN, 'Color', colors.matlab{4}, 'DisplayName', "Row Measures - Bag 2");
end
legend('Location', 'best');
xlabel("Time [s]");
ylabel("Row Angle Difference [deg]");