if ~show_error_series
    return
end

x_max = max(cellfun(@(x) max(x.s.sens_stamp), sensors));
t0 = linspace(0,x_max,100);

% ---------------- X MAP ----------------
figure('Name','Error - x map')
ylabel('error [m]')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    ax(f) = nexttile; hold on; grid on; f=f+1;
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3, 'HandleVisibility','off')
    plot_detections(sensors{i}.s.sens_stamp, sensors{i}.s.x_map_err,sensors{i}.s.max_det, sensors{i}.col, sensors{i}.name)
    xlim([0 inf]); ylim([-10 10]), ylabel('error [m]'), legend show;
end
xlabel('timestamp [s]');

% ---------------- Y MAP ----------------
figure('Name','Error - y map')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    ax(f) = nexttile; hold on; grid on; f=f+1;
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3, 'HandleVisibility','off')
    plot_detections(sensors{i}.s.sens_stamp, sensors{i}.s.y_map_err,sensors{i}.s.max_det, sensors{i}.col, sensors{i}.name)
    xlim([0 inf]); ylim([-10 10]), ylabel('error [m]'), legend show;
end
xlabel('timestamp [s]');

% ---------------- YAW MAP ----------------
figure('Name','Error - yaw map')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    ax(f) = nexttile; hold on; grid on; f=f+1;
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3, 'HandleVisibility','off')
    plot_detections(sensors{i}.s.sens_stamp, rad2deg(sensors{i}.s.yaw_map_err),sensors{i}.s.max_det, sensors{i}.col, sensors{i}.name)
    xlim([0 inf]); ylim([-10 10]), ylabel('error [deg]'), legend show;
end
xlabel('timestamp [s]');