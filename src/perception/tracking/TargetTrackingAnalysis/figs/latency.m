%% LATENCY FIGURE
figure('name','Detections - Latency', 'NumberTitle', 'off');
tiledlayout(4,1,'Padding','compact');

for i = 1:numel(sensors)
    axes(f) = nexttile([1,1]); f=f+1; hold on;
    s = sensors{i}.s;
    plot_detections(s.stamp, s.stamp - s.sens_stamp, 1, sensors{i}.col, sensors{i}.name, '-');
    ylabel(sprintf('%s [s]', sensors{i}.name)); legend show; grid on;
end
xlabel('timestamp [s]');