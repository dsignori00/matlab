clc
close all

%% Plot useful data from .mat files

d5 = din{5};
ax_fig = [];

time_0 = d5.C2_Safety__SAFETY_EPS_02__EPS_PinionAg(1,1);

%% Get fieldsname of relevant data

fn = fieldnames(d5);

fn_cell  = unique(fn(:,1));
d5.names = cell2struct(fn_cell, fn_cell, 1);

% Starting from here, you have to change the names of the plots in order to
% obtain the figures with the data you want to see (e.g., torque request,
% brakes temperature, ...)

%% Steering

set(0,'defaultAxesColorOrder', linspecer(1))
h           = figure;
h.Name      = "Steering";
ax_fig(end+1) = axes; hold all; box on; grid on; xlabel('Time [s]'), ylabel('Steering angle [deg]'),title('Steering'), legend show;
plot(d5.C2_Safety__SAFETY_EPS_02__EPS_PinionAg(:,1) - time_0, d5.C2_Safety__SAFETY_EPS_02__EPS_PinionAg(:,2), 'DisplayName', d5.names.C2_Safety__SAFETY_EPS_02__EPS_PinionAg);

%% Yaw rate

set(0,'defaultAxesColorOrder', linspecer(1))
h           = figure;
h.Name      = "Yaw Rate";
ax_fig(end+1) = axes; hold all; box on; grid on; xlabel('Time [s]'), ylabel('r [deg/s]'),title('Yaw rate'), legend show;
plot(IN_DATA.TIME, IN_DATA.YAW_RATE, 'DisplayName', 'Measured');

%% Velocity

set(0,'defaultAxesColorOrder', linspecer(2))
h           = figure;
h.Name      = "Velocity X";
ax_fig(end+1) = axes; hold all; box on; grid on; xlabel('Time [s]'), ylabel('Vx [km/h]'),title('Velocity X'), legend show;
plot(IN_DATA.TIME, IN_DATA.SPEED_1_FILT * 3.6, 'DisplayName', 'Reference')
plot(d_sim.polimi_time_s, d_sim.polimi_vx_meas_mps * 3.6, 'DisplayName', 'Simulated');

%% Throttle/brake

set(0,'defaultAxesColorOrder', linspecer(2))
h           = figure;
h.Name      = "Throttle/Brake";
ax_fig(end+1) = subplot(211); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Throttle [$\%$]'),title('Throttle'), legend show;
plot(d5.C2_Safety__SAFETY_PCU_vehicle_ST__PCU_accelerator_pedal(:,1) - time_0, d5.C2_Safety__SAFETY_PCU_vehicle_ST__PCU_accelerator_pedal(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_throttle * 100, 'DisplayName', 'Simulated');
ax_fig(end+1) = subplot(212); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Brake [$\%$]'),title('Brake'), legend show;
plot(d5.C2_Safety__SAFETY_PCU_vehicle_ST__PCU_accelerator_pedal(:,1) - time_0, d5.C2_Safety__SAFETY_PCU_vehicle_ST__PCU_accelerator_pedal(:,2)*0, 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, -d_sim.polimi_brake * 100, 'DisplayName', 'Simulated');

%% Longitudinal acceleration

set(0,'defaultAxesColorOrder', linspecer(2))
h           = figure;
h.Name      = "Longitudinal Acceleration";
ax_fig(end+1) = axes; hold all; box on; grid on; xlabel('Time [s]'), ylabel('Vx [km/h]'),title('Longitudinal acceleration'), legend show;
plot(IN_DATA.TIME, IN_DATA.ACCX, 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_ax_meas_mps2, 'DisplayName', 'Simulated');

%% Wheel Torques

set(0,'defaultAxesColorOrder', linspecer(3))
h           = figure;
h.Name      = "Wheel Torques";
title('Wheel Torques requests')
ax_fig(end+1) = subplot(221); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('FL'), legend show;
plot(d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_FL(:,1) - time_0, d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_FL(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_T_request_F_Nm*polimi_params.vehicle.tau_front, 'Linewidth', 1.2,'DisplayName', 'Simulated');

ax_fig(end+1) = subplot(222); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('FR'), legend show;
plot(d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_FR(:,1) - time_0, d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_FR(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_T_request_F_Nm*polimi_params.vehicle.tau_front, 'Linewidth', 1.2,'DisplayName', 'Simulated');

ax_fig(end+1) = subplot(223); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('RL'), legend show;
plot(d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_RL(:,1) - time_0, d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_RL(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_T_request_R_Nm*polimi_params.vehicle.tau_rear, 'Linewidth', 1.2,'DisplayName', 'Simulated');

ax_fig(end+1) = subplot(224); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('RR'), legend show;
plot(d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_RR(:,1) - time_0, d5.RSAFETY_PCU_wheel_torque_REQ__PCU_wheel_torque_RR(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_T_request_R_Nm*polimi_params.vehicle.tau_rear, 'Linewidth', 1.2,'DisplayName', 'Simulated');


%% Slip ratios 

% Wheel Speed
vx_wheel_FL = IN_DATA.WS_FL_RADPS * polimi_params.vehicle.R_front;
vx_wheel_FR = IN_DATA.WS_FR_RADPS * polimi_params.vehicle.R_front;
vx_wheel_RL = IN_DATA.WS_RL_RADPS * polimi_params.vehicle.R_rear;
vx_wheel_RR = IN_DATA.WS_RR_RADPS * polimi_params.vehicle.R_rear;

vx_wheels = [vx_wheel_FL vx_wheel_FR vx_wheel_RL vx_wheel_RR];
% Wheel Center Speed
vxFL = IN_DATA.VX - polimi_params.vehicle.t_front/2*IN_DATA.YAW_RATE;
vxFR = IN_DATA.VX  + polimi_params.vehicle.t_front/2*IN_DATA.YAW_RATE;
vxRL = IN_DATA.VX  - polimi_params.vehicle.t_rear/2*IN_DATA.YAW_RATE;
vxRR = IN_DATA.VX  + polimi_params.vehicle.t_rear/2*IN_DATA.YAW_RATE;

vyFL = -IN_DATA.VY + polimi_params.vehicle.Lf*IN_DATA.YAW_RATE;
vyFR = -IN_DATA.VY + polimi_params.vehicle.Lf*IN_DATA.YAW_RATE;

% Slip Ratio
slip_ratio_norm = zeros(length(IN_DATA.STEER),4);

vxWC_FL = vxFL.*cos(-IN_DATA.STEER/polimi_params.vehicle.Rsw) + vyFL.*sin(-IN_DATA.STEER/polimi_params.vehicle.Rsw);
vxWC_FR = vxFR.*cos(-IN_DATA.STEER/polimi_params.vehicle.Rsw) + vyFR.*sin(-IN_DATA.STEER/polimi_params.vehicle.Rsw);
vxWC_RL = vxRL;
vxWC_RR = vxRR;

slip_ratio_norm_fl = (vx_wheel_FL - vxWC_FL)./max(vxWC_FL,vx_wheel_FL);
slip_ratio_norm_fr = (vx_wheel_FR - vxWC_FR)./max(vxWC_FR,vx_wheel_FR);
slip_ratio_norm_rl = (vx_wheel_RL - vxWC_RL)./max(vxWC_RL,vx_wheel_RL);
slip_ratio_norm_rr = (vx_wheel_RR - vxWC_RR)./max(vxWC_RR,vx_wheel_RR);

% slip_ratio_norm = (vx_wheels - vxWC')./max(vxWC',vx_wheels);

slip_ratio_norm_fl = slip_ratio_norm_fl(IN_DATA.WS_FL_RADPS > 50);
slip_ratio_norm_fr = slip_ratio_norm_fr(IN_DATA.WS_FR_RADPS > 50);
slip_ratio_norm_rl = slip_ratio_norm_rl(IN_DATA.WS_RL_RADPS > 50);
slip_ratio_norm_rr = slip_ratio_norm_rr(IN_DATA.WS_RR_RADPS > 50);

set(0,'defaultAxesColorOrder', linspecer(2))
h = figure;
h.Name = 'Slip Ratios';
ax_fig(end+1) = subplot(211); hold all, xlabel('Time [s]'), ylabel('slip ratio [-]'), title('Front')
plot(IN_DATA.TIME(IN_DATA.WS_FL_RADPS > 50), slip_ratio_norm_fl - mean(slip_ratio_norm_fl))
plot(IN_DATA.TIME(IN_DATA.WS_FR_RADPS > 50), slip_ratio_norm_fr - mean(slip_ratio_norm_fr))
legend('FL','FR')
ax_fig(end+1) = subplot(212); hold all, xlabel('Time [s]'), ylabel('slip ratio [-]'), title('Rear')
plot(IN_DATA.TIME(IN_DATA.WS_RL_RADPS > 50), slip_ratio_norm_rl - mean(slip_ratio_norm_rl))
plot(IN_DATA.TIME(IN_DATA.WS_RR_RADPS > 50), slip_ratio_norm_rr - mean(slip_ratio_norm_rr))
legend('RL','RR')

%% Wheel speeds

set(0,'defaultAxesColorOrder', linspecer(3))
h           = figure;
h.Name      = "Wheel Speeds";
sgtitle('Wheel Speed')
ax_fig(end+1) = subplot(221); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Wheel speeds [rad/s]'),title('FL'), legend show;
plot(d5.C2_Safety__PCU_Vehicle_info_3_EPS__PCU_EPS_wheel_speed_FL(:,1) - time_0, d5.C2_Safety__PCU_Vehicle_info_3_EPS__PCU_EPS_wheel_speed_FL(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_wheel_speed_F_radps, 'DisplayName', 'Simulated');
% plot(d_sim.polimi_time_s, vx_wheels_cog_FL/polimi_params.vehicle.R_front, 'DisplayName', 'offline');

ax_fig(end+1) = subplot(222); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Wheel speeds [rad/s]'),title('FR'), legend show;
plot(d5.C2_Safety__PCU_Vehicle_info_3_EPS__PCU_EPS_wheel_speed_FR(:,1) - time_0, d5.C2_Safety__PCU_Vehicle_info_3_EPS__PCU_EPS_wheel_speed_FR(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_wheel_speed_F_radps, 'DisplayName', 'Simulated');
% plot(d_sim.polimi_time_s, vx_wheels_cog_FR/polimi_params.vehicle.R_front, 'DisplayName', 'offline');

ax_fig(end+1) = subplot(223); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Wheel speeds [rad/s]'),title('RL'), legend show;
plot(d5.C2_Safety__PCU_Vehicle_info_2_EPS__PCU_EPS_wheel_speed_RL(:,1) - time_0, d5.C2_Safety__PCU_Vehicle_info_2_EPS__PCU_EPS_wheel_speed_RL(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_wheel_speed_R_radps, 'DisplayName', 'Simulated');
% plot(d_sim.polimi_time_s, vx_wheels_cog_RL/polimi_params.vehicle.R_rear, 'DisplayName', 'offline');

ax_fig(end+1) = subplot(224); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Wheel speeds [rad/s]'),title('RR'), legend show;
plot(d5.C2_Safety__PCU_Vehicle_info_2_EPS__PCU_EPS_wheel_speed_RR(:,1) - time_0, d5.C2_Safety__PCU_Vehicle_info_2_EPS__PCU_EPS_wheel_speed_RR(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, d_sim.polimi_wheel_speed_R_radps, 'DisplayName', 'Simulated');
% plot(d_sim.polimi_time_s, vx_wheels_cog_RR/polimi_params.vehicle.R_rear, 'DisplayName', 'offline');

%% Battery

set(0,'defaultAxesColorOrder', linspecer(3))
h           = figure;
h.Name      = "Battery Charging";

ax_fig(end+1) = axes; hold all; box on; grid on; xlabel('Time [s]'), ylabel('SOC [0-100]'),title('Battery'), legend show;
plot(d_sim.polimi_time_s, d_sim.btt_SOC, 'DisplayName', 'Simulated - Polimi');

h           = figure;
h.Name      = "Battery Status";
ax_fig(end+1) = subplot(211); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Voltage [V]'),title('Batt. Voltage'), legend show;
plot(d_sim.polimi_time_s, d_sim.btt_voltage_V, 'DisplayName', 'Simulated - Polimi');

ax_fig(end+1) = subplot(212); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Current [A]'),title('Current'), legend show;
plot(d_sim.polimi_time_s, d_sim.btt_current_A, 'DisplayName', 'Simulated - Polimi');

h           = figure;
h.Name      = "Battery Temperature";
ax_fig(end+1) = axes; hold all; box on; grid on; xlabel('Time [s]'), ylabel('Temperature [$^\circ$C]'),title('Batt. Temperature'), legend show
plot(d_sim.polimi_time_s, d_sim.btt_temp_deg, 'DisplayName', 'Simulated - Polimi');

h           = figure;
h.Name      = "Battery Power Request";
ax_fig(end+1) = axes; hold all; box on; grid on; xlabel('Time [s]'), ylabel('Power [kW]'),title('Battery power request'), legend show
plot(d_sim.polimi_time_s, d_sim.polimi_P_battery_request/1000, 'DisplayName', 'Simulated - Polimi');
plot(d_sim.polimi_time_s, ones(1,length(d_sim.polimi_time_s)) * polimi_params.btt.MaxPwrRegen_W/1000 , '--k','DisplayName', 'Simulated - Polimi');

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Friction Torques Driver Command/After ABS-ESC Intervention

set(0,'defaultAxesColorOrder', linspecer(2))
h           = figure;
h.Name      = "Friction Torque Driver Command/After ABS-ESC Intervention";

ax_fig(end+1) = subplot(221); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('FL'), legend show;
plot(d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_FL(:,1) - time_0,d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_FL(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, -d_sim.polimi_Fbrake_wheel_front_N * polimi_params.vehicle.R_front, 'DisplayName', 'Simulated');

ax_fig(end+1) = subplot(222); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('FR'), legend show;
plot(d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_FR(:,1) - time_0,d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_FR(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, -d_sim.polimi_Fbrake_wheel_front_N* polimi_params.vehicle.R_front, 'DisplayName', 'Simulated');

ax_fig(end+1) = subplot(223); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('RL'), legend show;
plot(d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_RL(:,1) - time_0,d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_RL(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, -d_sim.polimi_Fbrake_wheel_rear_N* polimi_params.vehicle.R_rear, 'DisplayName', 'Simulated');

ax_fig(end+1) = subplot(224); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Torque [Nm]'),title('RR'), legend show;
plot(d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_RR(:,1) - time_0,d5.RSAFETY_DBC_friction_torque__DBC_friction_torque_est_RR(:,2), 'DisplayName', 'Measured');
plot(d_sim.polimi_time_s, -d_sim.polimi_Fbrake_wheel_rear_N * polimi_params.vehicle.R_rear, 'DisplayName', 'Simulated');


%% Plot brake temperature: only for grobnik dataset

% ADMM Disk Temperatures (messages from R&D sensors)
set(0,'defaultAxesColorOrder', linspecer(3))
h           = figure;
h.Name      = "Disk Temperatures";

ax_fig(end+1) = subplot(211); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Temperature [$^\circ$C]'),title('Front');
plot(d_sim.polimi_time_s, d_sim.polimi_Tbrk_F_deg,'Linewidth', 2, 'DisplayName', 'Polimi Est.');
legend show

ax_fig(end+1) = subplot(212); hold all; box on; grid on; xlabel('Time [s]'), ylabel('Temperature [$^\circ$C]'),title('Rear');
plot(d_sim.polimi_time_s,d_sim.polimi_Tbrk_R_deg,'Linewidth', 2, 'DisplayName', 'Polimi Est.');
legend show

linkaxes(ax_fig, 'x')
