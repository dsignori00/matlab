%% STATE FIGURE REL
figure('name', 'Filter - CoG');
tiledlayout(3,1,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plotDetections(s.sens_stamp, s.x_rel, s.max_det, sensors{i}.col, sensors{i}.name);
end
plotTT(tt.stamp, tt.x_rel, tt.max_opp, col.tt, 'tt');
if(compare); plotTT(tt2.stamp, tt2.x_rel, tt2.max_opp, col.tt2, name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.x_rel, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('x rel [m]'); legend show;

% pos y
axes(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plotDetections(s.sens_stamp, s.y_rel, s.max_det, sensors{i}.col, sensors{i}.name);
end
plotTT(tt.stamp, tt.y_rel, tt.max_opp, col.tt, 'tt');
if(compare); plotTT(tt2.stamp, tt2.y_rel, tt2.max_opp, col.tt2, name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.y_rel, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('y rel [m]'); legend show;

% rho dot
axes(f) = nexttile([1,1]); f=f+1; hold on;
plotDetections(rad_clust.sens_stamp, rad_clust.rho_dot, rad_clust.max_det, col.radar, 'Rad Clust');
plotTT(tt.stamp, tt.rho_dot, tt.max_opp, col.tt, 'tt');
if(compare); plotTT(tt2.stamp, tt2.rho_dot, tt2.max_opp, col.tt2, name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('rho dot [m/s]'); xlabel('timestamp [s]'); legend show;