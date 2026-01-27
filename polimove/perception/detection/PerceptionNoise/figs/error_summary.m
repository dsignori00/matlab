figure("Name","Error - Summary")

%% --- Positional errors (ellipse) ---
subplot(2,2,[1 3]); hold on; grid on; axis equal

for i = 1:numel(sensors)
    plot(sensors{i}.s.y_ellipse, sensors{i}.s.x_ellipse, ...
        'Color',sensors{i}.col,'LineWidth',2,'DisplayName',sensors{i}.name)
    scatter(sensors{i}.s.y_rel_mean, sensors{i}.s.x_rel_mean, ...
        'o','MarkerFaceColor',sensors{i}.col,'MarkerEdgeColor',sensors{i}.col,...
        'HandleVisibility','off')
end

xline(0,'--','LineWidth',0.3,'HandleVisibility','off')
yline(0,'--','LineWidth',0.3,'HandleVisibility','off')
title('Positional Errors')
xlabel('y rel [m]'); ylabel('x rel [m]')
legend

%% --- Range-rate error (Radar only) ---
rho_dot_idx = find(cellfun(@(s) s.has_rho_dot, sensors));
s = sensors{rho_dot_idx(1)};
ax1 = subplot(2,2,2); hold on; grid on
boxplot(s.s.rho_dot_err(:), 'Symbol', '')
xline(0, '--', 'LineWidth', 0.3, 'HandleVisibility', 'off')
title('Range Rate Error'); ylabel('range rate [m/s]'); xlabel(s.name); 
ylim([-s.s.rho_dot_std, s.s.rho_dot_std]), xlim([0.8 1.2]); xticklabels([])


%% --- Heading error ---
ax2 = subplot(2,2,4); hold on; grid on

yaw_err = [];
group   = {};
YawMaxStd = 0;

for i = 1:numel(sensors)
    e = rad2deg(sensors{i}.s.yaw_map_err(:));
    yaw_err = [yaw_err; e];
    group   = [group; repmat({sensors{i}.name}, numel(e), 1)];
    YawMaxStd = max(YawMaxStd, rad2deg(sensors{i}.s.yaw_map_std));
end

boxplot(yaw_err, group, 'Symbol','')
yline(0,'--','LineWidth',0.3,'HandleVisibility','off')
title('Heading Error')
ylabel('[deg]')
ylim([-2*YawMaxStd 2*YawMaxStd])
