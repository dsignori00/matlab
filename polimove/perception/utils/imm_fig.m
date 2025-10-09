%% FIGURE IMM
if(imm)
    figure('name','Imm')
    tiledlayout(3,1,'Padding','compact');
    
    % vx
    axes(f) = nexttile([1,1]);
    f=f+1;
    hold on;
    plot(tt.stamp,tt.vx(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
    if(use_ref || use_sim_ref)
        plot(tt.stamp_ref,tt.vx_ref,'Color',col.ref,'DisplayName','Ground Truth');
    end
    grid on;
    title('vx [m/s]');
    legend
    
    % ax
    axes(f) = nexttile([1,1]);
    f=f+1;
    hold on;
    plot(tt.stamp,tt.ax(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
    if(use_sim_ref)
        plot(tt.stamp_ref,tt.ax_ref,'Color',col.ref,'DisplayName','Ground Truth');
    end
    grid on;
    title('ax [m/s^2]');
    legend
    
    axes(f) = nexttile([1,1]);
    f=f+1;
    hold on;
    plot(tt.stamp,log.perception__opponents.opponents__ctra_prob(:,1:max_opp),'Color',col.radar,'DisplayName','CTRA');
    plot(tt.stamp,log.perception__opponents.opponents__ctrv_prob(:,1:max_opp),'Color',col.pointpillars,'DisplayName','CTRV');
    plot(tt.stamp,log.perception__opponents.opponents__cm_acc_prob(:,1:max_opp),'Color',col.lidar,'DisplayName','CONST ACC');
    plot(tt.stamp,log.perception__opponents.opponents__cm_dec_prob(:,1:max_opp),'Color',col.camera,'DisplayName','CONST DEC');
    grid on;
    title('Model Prob')
    linkaxes(axes,'x')
    legend
end