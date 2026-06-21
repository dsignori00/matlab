%% LATENCY FIGURE
figure('name','Detections - Latency', 'NumberTitle', 'off');

validSensors = [];
for i = 1:numel(sensors)
    s = sensors{i}.s;
    hasValidStamp = any(isfinite(s.stamp(:))) && any(isfinite(s.sens_stamp(:)));
    hasValidMeasure = any(isfinite(s.x_rel(:))) || any(isfinite(s.y_rel(:))) || ...
        any(isfinite(s.x_map(:))) || any(isfinite(s.y_map(:)));

    if hasValidStamp && hasValidMeasure
        validSensors(end+1) = i; %#ok<SAGROW>
    end
end

tiledlayout(max(1, numel(validSensors)),1,'Padding','compact');

for i = validSensors
    axes(f) = nexttile([1,1]); f=f+1; hold on;
    s = sensors{i}.s;
    plot_detections(s.stamp, s.stamp - s.sens_stamp, 1, sensors{i}.col, sensors{i}.name, '-');
    ylabel(sprintf('%s [s]', sensors{i}.name)); legend show; grid on;
end
xlabel('timestamp [s]');
