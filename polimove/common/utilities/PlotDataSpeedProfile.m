function plot_data_speed_profile(data)

%% Time 
MPS2MPH=3.6/1.6;

% speed - mu
figure, set(gcf, 'Color', 'White')
spt(1)=subplot(2,1,1);
hold on
ylabel('vx [mph]')
plot(data.time, MPS2MPH*data.vx_hat, 'LineWidth',1.5,'color','k', 'DisplayName','speed ego')
plot(data.time, MPS2MPH*data.vel_control_ref, 'LineWidth',1.5,'color','r', 'DisplayName','to low level ctrl')
plot(data.time, MPS2MPH*data.vel_profile_ref,'--', 'LineWidth',1.5,'color','b', 'DisplayName','speed profile ref')
plot(data.time, MPS2MPH*data.vel_profile_feas, 'LineWidth',1.5,'color','m', 'DisplayName','speed profile feas')
plot(data.time, MPS2MPH*data.vel_profile_ref_flat,'--', 'LineWidth',1.5,'color','c', 'DisplayName','speed profile flat')
plot(data.time, MPS2MPH*data.vel_decision_maker,'--', 'LineWidth',1.5,'color','g', 'DisplayName','decision maker')
legend show
    
spt(2)=subplot(6,1,4);
hold on
ylabel('mux acc [-]')
xlabel('time [s]')
plot(data.time, data.mux_acc.*data.mux_acc_gain_ref, 'LineWidth',1.5,'color','b', 'DisplayName','ref')
plot(data.time, data.mux_acc.*data.mux_acc_gain_feas, 'LineWidth',1.5,'color','g', 'DisplayName','feas')
legend show

spt(3)=subplot(6,1,5);
hold on
ylabel('mux dec [-]')
xlabel('time [s]')
plot(data.time, data.mux_dec.*data.mux_dec_gain_ref, 'LineWidth',1.5,'color','b', 'DisplayName','ref')
plot(data.time, data.mux_dec.*data.mux_dec_gain_feas, 'LineWidth',1.5,'color','g', 'DisplayName','feas')
legend show

spt(4)=subplot(6,1,6);
hold on
ylabel('muy [-]')
xlabel('time [s]')
plot(data.time, data.muy.*data.muy_gain_ref, 'LineWidth',1.5,'color','b', 'DisplayName','ref')
plot(data.time, data.muy.*data.muy_gain_feas, 'LineWidth',1.5,'color','g', 'DisplayName','feas')
legend show

linkaxes(spt,'x');

%% Space
figure, set(gcf, 'Color', 'White')
sps(1)=subplot(3,1,[1,2]);
hold on
ylabel('vx [mph]')
scatter3(data.track_idx,data.vel_profile_ref*3.6,data.time,[],data.lap_count,'.')

sps(2)=subplot(3,3,7);
hold on
ylabel('$\mu_x$ acc [-]')
xlabel('idx')
scatter3(data.track_idx,data.mux_acc .* data.mux_acc_gain_ref,data.time,[],data.lap_count,'.')

sps(3)=subplot(3,3,8);
hold on
ylabel('$\mu_x$ dec [-]')
xlabel('idx')
scatter3(data.track_idx,data.mux_dec .* data.mux_dec_gain_ref,data.time,[],data.lap_count,'.')

sps(4)=subplot(3,3,9);
hold on
ylabel('$\mu_y$ [-]')
xlabel('idx')
scatter3(data.track_idx,data.muy .* data.muy_gain_ref,data.time,[],data.lap_count,'.')

linkaxes(sps,'x');




