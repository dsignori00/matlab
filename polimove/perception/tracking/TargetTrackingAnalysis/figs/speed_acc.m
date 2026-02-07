%% SPEED AND ACC
figure('name', 'Filter - Speed Acc');
tiledlayout(3,1,'Padding','compact');

% vx
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot_tt(tt.stamp, tt.vx, tt.max_opp, col.tt, name1);
if(compare); plot_tt(tt2.stamp, tt2.vx, tt2.max_opp, col.tt2, name2); end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.vx,'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('vx [m/s]'); ylim([0 inf]); legend show;

% ax
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot_tt(tt.stamp, tt.ax, tt.max_opp, col.tt, name1);
if(compare); plot_tt(tt2.stamp, tt2.ax, tt2.max_opp, col.tt2, name2); end
if(use_sim_ref); plot(gt.stamp,gt.ax,'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('ax [m/s$^2$]'); legend show; 

% yaw rate
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot_tt(tt.stamp, (tt.yaw_rate), tt.max_opp, col.tt, name1);
if(compare); plot_tt(tt2.stamp, (tt2.yaw_rate), tt2.max_opp, col.tt2, name2); end
grid on; ylabel('yaw rate [deg/s]'); legend show; xlabel('timestamp [s]');