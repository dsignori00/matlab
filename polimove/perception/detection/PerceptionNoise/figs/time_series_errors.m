if ~show_error_series
    return
end

% TO DO: USE ASSOCIATED MEASURES
gat_thr = 10;

x_max = max(cellfun(@(x) max(x.s.sens_stamp), sensors));
t0 = linspace(0,x_max,100);

% ---------------- X MAP ----------------
figure('Name','Error: x_map')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    nexttile; hold on; grid on
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3)
    plot(sensors{i}.s.sens_stamp, sensors{i}.s.x_map_err,'*','Color',sensors{i}.col)
    title([sensors{i}.name '_x_map [m]'])
    xlim([0 inf]); ylim([-gat_thr gat_thr])
end

% ---------------- Y MAP ----------------
figure('Name','Error: y_map')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    nexttile; hold on; grid on
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3)
    plot(sensors{i}.s.sens_stamp, sensors{i}.s.y_map_err,'*','Color',sensors{i}.col)
    title([sensors{i}.name '_y_map [m]'])
    xlim([0 inf]); ylim([-gat_thr gat_thr])
end

% ---------------- YAW MAP ----------------
figure('Name','Error: yaw_map')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    nexttile; hold on; grid on
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3)
    plot(sensors{i}.s.sens_stamp, rad2deg(sensors{i}.s.yaw_map_err),'*','Color',sensors{i}.col)
    title([sensors{i}.name '_yaw_map [deg]'])
    xlim([0 inf]); ylim([-10 10])
end