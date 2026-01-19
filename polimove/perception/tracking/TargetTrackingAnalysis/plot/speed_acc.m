%% SPEED AND ACC
figure('name', 'Filter - Speed Acc');
tiledlayout(2,1,'Padding','compact');

% vx
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(tt.stamp,tt.vx(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp,tt2.vx(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.vx,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('vx [m/s]'); ylim([0 inf]);

% ax
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(tt.stamp,tt.ax(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp,tt2.ax(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName','tt'); end
if(use_sim_ref); plot(gt.stamp,gt.ax,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('ax [m/s$^2$]');

linkaxes(axes,'x');
xlim(x_lim);