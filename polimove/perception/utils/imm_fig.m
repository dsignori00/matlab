%% FIGURE IMM
if(imm)
    figure('name','Imm')
    tiledlayout(3,1,'Padding','compact');
    
    % vx
    axes(f) = nexttile([1,1]); f=f+1; hold on;
    plot(tt.stamp,tt.vx(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
    if(use_ref || use_sim_ref); plot(gt.stamp,gt.vx,'Color',col.ref,'DisplayName','ref'); end
    if(compare); plot(tt2.stamp,tt2.vx(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName','tt'); end
    grid on;
    ylabel('vx [m/s]');
    legend
    
    % ax
    axes(f) = nexttile([1,1]); f=f+1; hold on;
    plot(tt.stamp,tt.ax(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
    if(use_sim_ref); plot(gt.stamp,gt.ax,'Color',col.ref,'DisplayName','ref'); end
    if(compare); plot(tt2.stamp,tt2.ax(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName','tt'); end
    grid on; ylabel('ax [m/s$^2$]'); legend
    
    axes(f) = nexttile([1,1]); f=f+1; hold on;
    plot(tt.stamp,log.perception__opponents.opponents__ctra_prob(:,1:tt.max_opp),'Color',col.radar,'DisplayName','CTRA');
    plot(tt.stamp,log.perception__opponents.opponents__ctrv_prob(:,1:tt.max_opp),'Color',col.pointpillars,'DisplayName','CTRV');
    plot(tt.stamp,log.perception__opponents.opponents__cm_acc_prob(:,1:tt.max_opp),'Color',col.lidar,'DisplayName','CONST ACC');
    plot(tt.stamp,log.perception__opponents.opponents__cm_dec_prob(:,1:tt.max_opp),'Color',col.camera,'DisplayName','CONST DEC');
    grid on; ylabel('model probs [\%]'); legend
    linkaxes(axes,'x')
end