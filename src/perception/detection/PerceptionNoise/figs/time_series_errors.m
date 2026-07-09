if ~show_error_series
    return
end

x_max = -inf;
for k = 1:numel(sensors)
    if ~isempty(sensors{k}.s.sens_stamp)
        x_max = max(x_max, max(sensors{k}.s.sens_stamp(:)));
    end
end
t0 = linspace(0,x_max,100);

% ---------------- X MAP ----------------
figure('Name','Error - x map')
ylabel('error [m]')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    ax(f) = nexttile; hold on; grid on; f=f+1;
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3, 'HandleVisibility','off')
    plot_detections(sensors{i}.s.sens_stamp, gated_error(sensors{i}.s, 'x_map_err', err_thr), 1, sensors{i}.col, sensors{i}.name)
    xlim([0 inf]); ylim(y_err_lim), ylabel('error [m]'), legend show;
end
xlabel('timestamp [s]');

% ---------------- Y MAP ----------------
figure('Name','Error - y map')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    ax(f) = nexttile; hold on; grid on; f=f+1;
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3, 'HandleVisibility','off')
    plot_detections(sensors{i}.s.sens_stamp, gated_error(sensors{i}.s, 'y_map_err', err_thr), 1, sensors{i}.col, sensors{i}.name)
    xlim([0 inf]); ylim(y_err_lim), ylabel('error [m]'), legend show;
end
xlabel('timestamp [s]');

% ---------------- YAW MAP ----------------
figure('Name','Error - yaw map')
tiledlayout(numel(sensors),1,'Padding','compact')

for i = 1:numel(sensors)
    ax(f) = nexttile; hold on; grid on; f=f+1;
    plot(t0, zeros(size(t0)),'--k','LineWidth',0.3, 'HandleVisibility','off')
    plot_detections(sensors{i}.s.sens_stamp, gated_error(sensors{i}.s, 'yaw_map_err', err_thr), 1, sensors{i}.col, sensors{i}.name)
    xlim([0 inf]); ylim(y_err_lim), ylabel('error [deg]'), legend show;
end
xlabel('timestamp [s]');

function err = gated_error(sensor, field, err_thr)
    gate = hypot(sensor.x_map_err(:,1), sensor.y_map_err(:,1)) < err_thr;
    err = sensor.(field)(:,1);
    err(~gate) = NaN;
end
