%% LATENCY FIGURE
figure('name','Detections - Latency', 'NumberTitle', 'off');

movingAverageWindowSeconds = 2;

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
    latencies = s.stamp - s.sens_stamp;

    filterInputStamp = s.stamp(:);
    filterInputLatencies = latencies(:);
    validLatency = isfinite(filterInputStamp) & isfinite(filterInputLatencies);
    [sortedStamp, order] = sort(filterInputStamp(validLatency));
    sortedLatencies = filterInputLatencies(validLatency);
    sortedLatencies = sortedLatencies(order);

    [filterStamp, ~, stampGroup] = unique(sortedStamp);
    meanLatency = accumarray(stampGroup, sortedLatencies, [], @mean);
    filteredLatency = movmean(meanLatency, movingAverageWindowSeconds, ...
        'SamplePoints', filterStamp);

    plot_detections(s.stamp, latencies, 1, sensors{i}.col, sensors{i}.name, '-');
    plot(filterStamp, filteredLatency, ...
        'Color', 'k', ...
        'LineWidth', 2.5, ...
        'DisplayName', sprintf('moving average (%.1f s)', movingAverageWindowSeconds));
    ylabel(sprintf('%s [s]', sensors{i}.name)); legend show; grid on;
end
xlabel('timestamp [s]');
