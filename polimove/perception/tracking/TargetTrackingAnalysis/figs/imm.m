%% FIGURE IMM

if ~isfield(tt,'opponents__ctra_prob')
    return;
end

figure('name','Imm')
tiledlayout(3,1,'Padding','compact');

if(~exist('use_sim_ref','var'))
    use_sim_ref = false;
end

% vx
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(repmat(tt.stamp,tt.max_opp, 1),tt.vx(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp,gt.vx,'Color',col.ref,'DisplayName','ref'); end
if(compare); plot(repmat(tt2.stamp,tt2.max_opp, 1),tt2.vx(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName','tt'); end
grid on;
ylabel('vx [m/s]');
legend

% ax
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(repmat(tt.stamp,tt.max_opp, 1),tt.ax(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
if(use_sim_ref); plot(gt.stamp,gt.ax,'Color',col.ref,'DisplayName','ref'); end
if(compare); plot(repmat(tt2.stamp,tt2.max_opp, 1),tt2.ax(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName','tt'); end
grid on; ylabel('ax [m/s$^2$]'); legend

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(tt.stamp,log.perception__opponents.opponents__ctra_prob(:,1),'Color',col.radar,'DisplayName','CTRA');
plot(tt.stamp,log.perception__opponents.opponents__ctrv_prob(:,1),'Color',col.pp,'DisplayName','CTRV');
plot(tt.stamp,log.perception__opponents.opponents__cm_acc_prob(:,1),'Color',col.lidar,'DisplayName','CCP - A');
plot(tt.stamp,log.perception__opponents.opponents__cm_dec_prob(:,1),'Color',col.camera,'DisplayName','CCP - B');
grid on; ylabel('model probs [\%]'); legend

xlabel("Time [s]");