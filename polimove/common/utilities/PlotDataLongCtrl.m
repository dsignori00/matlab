function plot_data_long_ctrl(data)
%% Time 
MPS2MPH=3.6/1.6;
kt=1;

%% Longitudinal controller
% speed and controller param
figure, set(gcf, 'Color', 'White')
spt(kt)=subplot(4,4,1:12);
kt=kt+1;
hold on
ylabel('vx [mph]')
plot(data.time, MPS2MPH*data.long_vel_ref, 'LineWidth',1.5,'color','r', 'DisplayName','v ref')
plot(data.time, MPS2MPH*data.vx_hat, 'LineWidth',1.5,'color','b', 'DisplayName','v hat')

spt(kt)=subplot(4,4,13);
kt=kt+1;
hold on
ylabel('acc gain [-]'), xlabel('time [s]')
plot(data.time, data.acc_i_gain, 'LineWidth',1.5,'color','r', 'DisplayName','acc gain')

spt(kt)=subplot(4,4,14);
kt=kt+1;
hold on
ylabel('speed gain multiplier [-]'), xlabel('time [s]')
plot(data.time, data.speed_gain, 'LineWidth',1.5,'color','b', 'DisplayName','speed gain,')

spt(kt)=subplot(4,4,15);
kt=kt+1;
hold on
ylabel('speed zero multiplier [-]'), xlabel('time [s]')
plot(data.time, data.speed_zero, 'LineWidth',1.5,'color','g', 'DisplayName','speed zero')

spt(kt)=subplot(4,4,16);
kt=kt+1;
hold on
ylabel('speed pole multiplier [-]'), xlabel('time [s]')
plot(data.time, data.speed_pole, 'LineWidth',1.5,'color','c', 'DisplayName','speed pole')
legend show

linkaxes(spt,'x');


% controller signals 
figure, set(gcf, 'Color', 'White')
spt(kt)=subplot(3,1,1);
kt=kt+1;
hold on
ylabel('vx [mph]')
plot(data.time, MPS2MPH*data.long_vel_ref, 'LineWidth',1.5,'color','r', 'DisplayName','v ref')
plot(data.time, MPS2MPH*data.vx_hat, 'LineWidth',1.5,'color','b', 'DisplayName','v hat')
legend show
    
spt(kt)=subplot(3,1,2);
kt=kt+1;
hold on
ylabel('ax [mps2]')
xlabel('time [s]')
plot(data.time, data.long_acc_ctrl, 'LineWidth',1.5,'color','g', 'DisplayName','acc ref (acc ctrl output)')
plot(data.time, data.long_acc,'--', 'LineWidth',1.5,'color','b', 'DisplayName','acc derivated')
plot(data.time, data.long_acc_ref, 'LineWidth',1.5,'color','r', 'DisplayName','ref from speed ctrl')
legend show

spt(kt)=subplot(3,1,3);
kt=kt+1;
hold on
ylabel('ax [mps2]')
xlabel('time [s]')
plot(data.time, data.long_acc_min, 'LineWidth',1.5,'color','g', 'DisplayName','long_acc_min')
plot(data.time, data.long_acc_ref, 'LineWidth',1.5,'color','r', 'DisplayName','ref from speed ctrl')
plot(data.time, data.long_acc_max, 'LineWidth',1.5,'color','g', 'DisplayName','long_acc_mmax')
legend show


% speed - throtte - engine rev - brake
figure, set(gcf, 'Color', 'White')
spt(kt)=subplot(4,1,1);
kt=kt+1;
hold on
ylabel('vx [mph]')
plot(data.time, MPS2MPH*data.long_vel_ref, 'LineWidth',1.5,'color','r', 'DisplayName','v ref')
plot(data.time, MPS2MPH*data.vx_hat, 'LineWidth',1.5,'color','b', 'DisplayName','v hat')
legend show
    
spt(kt)=subplot(4,1,2);
kt=kt+1;
hold on
ylabel('throttle [0-1]')
plot(data.time, data.throttle, 'LineWidth',1.5,'color','r', 'DisplayName','vehicle fbk')
plot(data.time, data.throttle_pedal_ctrl, 'LineWidth',1.5,'color','b', 'DisplayName','ctrl')
legend show

spt(kt)=subplot(4,1,3);
kt=kt+1;
hold on
ylabel('Engine RPM')
plot(data.time, data.engine_rpm, 'LineWidth',1.5,'color','r', 'DisplayName','engine rpm')
legend show
  
spt(kt)=subplot(4,1,4);
kt=kt+1;
hold on
ylabel('brake [kPa]')
xlabel('time [s]')
plot(data.time, data.p_brake_front,'--', 'LineWidth',1.5,'color','r', 'DisplayName','vehicle fbk front')
plot(data.time, data.p_brake_rear,'--', 'LineWidth',1.5,'color','b', 'DisplayName','vehicle fbk rear')
plot(data.time, data.p_brake_ctrl/1000, 'LineWidth',1.5,'color','g', 'DisplayName','ctrl')
legend show

linkaxes(spt,'x');



%% Space 
ks=1;

% plot long controller in space
figure, set(gcf, 'Color', 'White')
    
sps(ks)=subplot(2,1,1);
ks=ks+1;
hold on
ylabel('vx[kph]')
scatter3(data.track_idx*0.5,data.long_vel_ref*3.6,data.time,[],data.lap_count,'.')

sps(ks)=subplot(2,1,2);
ks=ks+1;
hold on
ylabel('vx[kph]')
scatter3(data.track_idx*0.5,data.vx_hat*3.6,data.time,[],data.lap_count,'.')

linkaxes(sps,'x');

end