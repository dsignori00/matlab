%% RANGE
figure('name', 'Detections - Count');
tiledlayout(2,1,'Padding','compact');

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot_area(tt.stamp, log.perception__opponents.opponents__rad_clust_meas, tt.max_opp, col.radar,        'Rad Clust');
plot_area(tt.stamp, log.perception__opponents.opponents__lid_pp_meas,    tt.max_opp, col.pp, 'Lid PP');
plot_area(tt.stamp, log.perception__opponents.opponents__lid_clust_meas, tt.max_opp, col.lidar,        'Lid Clust');
plot_area(tt.stamp, log.perception__opponents.opponents__cam_yolo_meas,  tt.max_opp, col.camera,       'Camera');
grid on; ylabel('Count'); legend show; xlabel('timestamp [s]');


%% GLOBAL OOSM ANALYSIS (multi-sensor)

allStamp     = [];
allSensStamp = [];
allSensorId  = [];

for i = 1:numel(sensors)
    s = sensors{i}.s;
    n = numel(s.stamp);

    allStamp     = [allStamp;     s.stamp(:)];
    allSensStamp = [allSensStamp; s.sens_stamp(:)];
    allSensorId  = [allSensorId;  repmat(i,n,1)];
end

% Sort by arrival time (filter iteration order)
[allStamp, ord] = sort(allStamp);
allSensStamp    = allSensStamp(ord);
allSensorId     = allSensorId(ord);

% Detect reprocessed (OOSM) measurements
N = numel(allStamp);
isReprocessed = false(N,1);

maxSensStamp = -inf;
for k = 1:N
    if allSensStamp(k) < maxSensStamp
        isReprocessed(k) = true;
    else
        maxSensStamp = allSensStamp(k);
    end
end

% Count OOSM per filter iteration
[iterStamp, ~, iterIdx] = unique(allStamp);
numReprocessedPerIter = accumarray(iterIdx, isReprocessed);

% latency figure with OOSM overlay
axes(f) = nexttile([1,1]);  f = f + 1; hold on;
stairs(iterStamp, numReprocessedPerIter, 'Color', col.tt, 'DisplayName','OOSM count');
ylabel('reprocessed measures [-]'); xlabel('timestamp [s]');
