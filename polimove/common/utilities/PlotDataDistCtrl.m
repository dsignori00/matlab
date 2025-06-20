function plot_data_dist_ctrl(data)

%% Time 
MPS2MPH=3.6/1.6;
figure, set(gcf, 'Color', 'White')
    
spt(1)=subplot(3,1,1);
hold on
ylabel('vx [mph]')
plot(data.time, MPS2MPH*data.long_vel_ref, 'LineWidth',1.5,'color','r', 'DisplayName','vx ref')
plot(data.time, MPS2MPH*data.long_vel_opponent, 'LineWidth',1.5,'color','b', 'DisplayName','vx opponent')
plot(data.time, MPS2MPH*data.long_vel, 'LineWidth',1.5,'color','g', 'DisplayName','vx ego')
legend show
    
spt(2)=subplot(3,1,2);
hold on
ylabel('vx [mph]')
xlabel('time [s]')
plot(data.time, MPS2MPH*data.long_vel_opponent, 'LineWidth',1.5,'color','r', 'DisplayName','long ctrl filt')
plot(data.time, MPS2MPH*data.v_opp, 'LineWidth',1.5,'color','b', 'DisplayName','local planner')
legend show

spt(3)=subplot(3,1,3);
hold on
ylabel('opp dist [m]')
xlabel('time [s]')
plot(data.time, data.dist_ref, 'LineWidth',1.5,'color','r', 'DisplayName','dist ref')
plot(data.time, data.dist_meas, 'LineWidth',1.5,'color','b', 'DisplayName','dist meas')
legend show

linkaxes(spt,'x');

   


%% Space
% figure, set(gcf, 'Color', 'White')
%     
% sps(1)=subplot(3,1,[1,2]);
% hold on
% ylabel('vx [mph]')
% scatter3(data.track_idx,data.vel_profile_ref*3.6,data.time,[],data.lap_count,'.')
% 
% sps(2)=subplot(3,3,7);
% hold on
% ylabel('$\mu_x$ acc [-]')
% xlabel('idx')
% scatter3(data.track_idx,data.mux_acc .* data.mux_acc_gain_ref,data.time,[],data.lap_count,'.')
% 
% sps(3)=subplot(3,3,8);
% hold on
% ylabel('$\mu_x$ dec [-]')
% xlabel('idx')
% scatter3(data.track_idx,data.mux_dec .* data.mux_dec_gain_ref,data.time,[],data.lap_count,'.')
% 
% sps(4)=subplot(3,3,9);
% hold on
% ylabel('$\mu_y$ [-]')
% xlabel('idx')
% scatter3(data.track_idx,data.muy .* data.muy_gain_ref,data.time,[],data.lap_count,'.')
% 
% linkaxes(sps,'x');




