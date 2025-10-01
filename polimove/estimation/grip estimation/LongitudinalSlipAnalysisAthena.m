clearvars -except log
% close all

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log','../../../../02_Data/');
    load(fullfile(path,file));
end

%% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(groot,'defaultAxesTickLabelInterpreter','none');  
set(0, 'DefaultLineLineWidth', 1);

%% interpolation
fs=100;
t=min(log.novatel_left__bestgnsspos__header__stamp__tot):1/fs:max(log.novatel_left__bestgnsspos__header__stamp__tot);

% kistler
t_kist = double(log.novatel_left__bestvel__header__stamp__tot)-double(log.time_offset_nsec)*1e-9;
[t_kist_uniq,idx,~] = unique(t_kist);
vx_uniq = log.novatel_left__bestvel__hor_speed(idx);
vx_interp = interp1(t_kist_uniq, vx_uniq, t, 'linear');
vx_interp(isnan(vx_interp)) = 0;

% vectornav
t_vec = log.novatel_left__bestgnsspos__header__stamp__tot;
[t_vec_uniq,idx,~] = unique(t_vec);
r_uniq = log.novatel_left__bestgnsspos__header__stamp__tot(idx);
r_interp = interp1(t_vec_uniq, r_uniq, t, 'linear');
r_interp(isnan(r_interp)) = 0;
ax_uniq = log.novatel_left__rawimu__linear_acceleration__x(idx);
ax_interp = interp1(t_vec_uniq, ax_uniq, t, 'linear');
ax_interp(isnan(ax_interp)) = 0;
ay_uniq = log.novatel_left__rawimu__linear_acceleration__y(idx);
ay_interp = interp1(t_vec_uniq, ay_uniq, t, 'linear');
ay_interp(isnan(ay_interp)) = 0;

% steer
t_steer = log.vehicle_fbk__steering_fbk_stamp__tot;
[t_steer_uniq,idx,~] = unique(t_steer);
angle_uniq = log.vehicle_fbk__steering_wheel_angle(idx);
angle_interp = interp1(t_steer_uniq, angle_uniq, t, 'linear');
angle_interp(isnan(angle_interp)) = 0;

% wheel speeds
t_wheels = log.vehicle_fbk__wheel_speed_fbk_stamp__tot;
[t_wheels_uniq,idx,~] = unique(t_wheels);
ome_fl_uniq = log.vehicle_fbk__v_fl(idx);
ome_fl_interp = interp1(t_wheels_uniq, ome_fl_uniq, t, 'linear');
ome_fl_interp(isnan(ome_fl_interp)) = 0;
ome_fr_uniq = log.vehicle_fbk__v_fr(idx);
ome_fr_interp = interp1(t_wheels_uniq, ome_fr_uniq, t, 'linear');
ome_fr_interp(isnan(ome_fr_interp)) = 0;
ome_rl_uniq = log.vehicle_fbk__v_rl(idx);
ome_rl_interp = interp1(t_wheels_uniq, ome_rl_uniq, t, 'linear');
ome_rl_interp(isnan(ome_rl_interp)) = 0;
ome_rr_uniq = log.vehicle_fbk__v_rr(idx);
ome_rr_interp = interp1(t_wheels_uniq, ome_rr_uniq, t, 'linear');
ome_rr_interp(isnan(ome_rr_interp)) = 0;

% % temperatures
% t_tires = log.vehicle_fbk_eva__wheel_speed_fbk_stamp__tot;
% [t_tires_uniq,idx,~] = unique(t_tires);
% temp_rl_uniq = log.vehicle_fbk_eva__tyre_ext_temp_center_rl(idx);
% temp_rl_interp = interp1(t_tires_uniq, temp_rl_uniq, t, 'linear');
% temp_rl_interp(isnan(temp_rl_interp)) = 0;
% temp_int_rl_uniq = log.vehicle_fbk_eva__tyre_internal_temp_rl(idx);
% temp_int_rl_interp = interp1(t_tires_uniq, temp_int_rl_uniq, t, 'linear');
% temp_int_rl_interp(isnan(temp_int_rl_interp)) = 0;

% % suspension
% t_dump = log.vehicle_fbk_eva__wheel_speed_fbk_stamp__tot;
% [t_dump_uniq,idx,~] = unique(t_dump);
% stroke_rl_uniq = log.vehicle_fbk_eva__dumper_stroke_rl(idx);
% stroke_rl_interp = interp1(t_dump_uniq, stroke_rl_uniq, t, 'linear');
% stroke_rl_interp(isnan(stroke_rl_interp)) = 0;
% stroke_r3rd_uniq = log.vehicle_fbk_eva__dumper_stroke_r3rd(idx);
% stroke_r3rd_interp = interp1(t_dump_uniq, stroke_r3rd_uniq, t, 'linear');
% stroke_r3rd_interp(isnan(stroke_r3rd_interp)) = 0;
% ride_uniq = log.vehicle_fbk_eva__ride_height_rear(idx);
% ride_interp = interp1(t_dump_uniq, ride_uniq, t, 'linear');
% ride_interp(isnan(ride_interp)) = 0;

% loads
% t_vfbk = log.vehicle_fbk_eva__bag_timestamp;
% load_f_meas = 9.81*interp1(t_vfbk, log.vehicle_fbk_eva__load_wheel_fl+log.vehicle_fbk_eva__load_wheel_fr, t, 'linear');
% load_f_meas(isnan(load_f_meas)) = 0;
% load_r_meas = 9.81*interp1(t_vfbk, log.vehicle_fbk_eva__load_wheel_rl+log.vehicle_fbk_eva__load_wheel_rr, t, 'linear');
% load_r_meas(isnan(load_r_meas)) = 0;
% 
% gearshift = interp1(t_vfbk(1:end-1), double(diff(log.vehicle_fbk_eva__requested_gear_ack)), t, 'linear');
% gearshift(isnan(gearshift)) = 0;
% 
% % brakes
% t_brakes = log.vehicle_fbk_eva__rl_brake_fbk_stamp__tot;
% [t_brakes_uniq,idx,~] = unique(t_brakes);
% brake_rl_uniq = log.vehicle_fbk_eva__rl_brake(idx);
% brake_rl_interp = interp1(t_brakes_uniq, brake_rl_uniq, t, 'linear');
% brake_rl_interp(isnan(brake_rl_interp)) = 0;
% brake_temp_rl_uniq = log.vehicle_fbk_eva__brake_temp_rl(idx);
% brake_temp_rl_interp = interp1(t_brakes_uniq, brake_temp_rl_uniq, t, 'linear');
% brake_temp_rl_interp(isnan(brake_temp_rl_interp)) = 0;
% 
% % misc
% t_traj = log.traj_server__stamp__tot;
% [t_traj_uniq,idx,~] = unique(t_traj);
% s_uniq = double(log.traj_server__closest_idx_ref(idx));
% s_interp = interp1(t_traj_uniq, s_uniq, t, 'linear');
% s_interp(isnan(s_interp)) = 0;
% t_eng = log.vehicle_fbk_eva__rpm_fbk_stamp__tot;
% [t_eng_uniq,idx,~] = unique(t_eng);
% rpm_uniq = double(log.traj_server__closest_idx_ref(idx));
% rpm_interp = interp1(t_eng_uniq, rpm_uniq, t, 'linear');
% rpm_interp(isnan(rpm_interp)) = 0;

%% filtering
fs = 100;
f_c = 5;
omega_c = 2 * pi * f_c;
filt_tf = tf(omega_c^2, [1 2*omega_c omega_c^2]);
[filt_num, filt_den] = tfdata(c2d(filt_tf, 1/fs, 'tustin'), 'v');

filt_tf_deriv = tf(omega_c^2*[1 0], [1 2*omega_c omega_c^2]);
[filt_num_deriv, filt_den_deriv] = tfdata(c2d(filt_tf_deriv, 1/fs, 'tustin'), 'v');

omega_c_lambda = 2 * pi * 50;
filt_tf_lambda = tf(omega_c_lambda^2, [1 2*omega_c_lambda omega_c_lambda^2]);
[filt_num_lambda, filt_den_lambda] = tfdata(c2d(filt_tf_lambda, 1/fs, 'tustin'), 'v');

omega_c_lambda = 2 * pi * 5;
filt_tf_deriv = tf(omega_c_lambda^2*[1 0], [1 2*omega_c_lambda omega_c_lambda^2]);
[filt_num_deriv_lambda, filt_den_deriv_lambda] = tfdata(c2d(filt_tf_deriv, 1/fs, 'tustin'), 'v');

vx_filt = filtfilt(filt_num, filt_den, vx_interp);
vy_filt = filtfilt(filt_num, filt_den ,vy_interp);
r_filt = filtfilt(filt_num, filt_den ,r_interp);
% rdot_filt = filtfilt(filt_num_deriv, filt_den_deriv, r_interp);
angle_filt = filtfilt(filt_num, filt_den ,angle_interp);
ax_filt = filtfilt(filt_num, filt_den ,ax_interp);
ay_filt = filtfilt(filt_num, filt_den ,ay_interp);

% temp_rl_filt = filtfilt(filt_num, filt_den ,temp_rl_interp);
% temp_int_rl_filt = filtfilt(filt_num, filt_den ,temp_int_rl_interp);
% brake_rl_filt = filtfilt(filt_num, filt_den ,brake_rl_interp);
% brake_temp_rl_filt = filtfilt(filt_num, filt_den ,brake_temp_rl_interp);
% 
% load_f_meas_filt = filtfilt(filt_num, filt_den ,load_f_meas);
% load_r_meas_filt = filtfilt(filt_num, filt_den ,load_r_meas);
% 
% gearshift_filt = filtfilt(filt_num, filt_den ,gearshift);
% 
% 
% stroke_r3rd_filt = filtfilt(filt_num, filt_den ,stroke_r3rd_interp);
% stroke_rl_filt = filtfilt(filt_num, filt_den ,stroke_rl_interp);
% ride_filt = filtfilt(filt_num, filt_den ,ride_interp);

ome_fl_filt = filtfilt(filt_num_lambda, filt_den_lambda, ome_fl_interp);
ome_fr_filt = filtfilt(filt_num_lambda, filt_den_lambda, ome_fr_interp);
ome_rl_filt = filtfilt(filt_num_lambda, filt_den_lambda, ome_rl_interp);
ome_rr_filt = filtfilt(filt_num_lambda, filt_den_lambda, ome_rr_interp);

% ome_fl_filt = ome_fl_interp;
% ome_fr_filt = ome_fr_interp;
% ome_rl_filt = ome_rl_interp;
% ome_rr_filt = ome_rr_interp;

ome_dot_fl_filt = filtfilt(filt_num_deriv_lambda, filt_den_deriv_lambda, ome_fl_interp);
ome_dot_fr_filt = filtfilt(filt_num_deriv_lambda, filt_den_deriv_lambda, ome_fr_interp);
ome_dot_rl_filt = filtfilt(filt_num_deriv_lambda, filt_den_deriv_lambda, ome_rl_interp);
ome_dot_rr_filt = filtfilt(filt_num_deriv_lambda, filt_den_deriv_lambda, ome_rr_interp);

% ome_dot_rl_filt_2 = filtfilt(filt_num_deriv_lambda, filt_den_deriv_lambda, ome_rl_interp);
% ome_dot_rr_filt_2 = filtfilt(filt_num_deriv_lambda, filt_den_deriv_lambda, ome_rr_interp);
% figure;hold on;plot(ome_dot_rl_filt_2);plot(ome_dot_rl_filt)
%% vy correction, alpha computation
FRONT_LENGTH = 1.654;
TOT_LENGTH = 3.115;
FRONT_TRACK = 1.61;
REAR_TRACK = 1.51;
TRACK = 1.56;

h = 0.3;
M = 760;
Clf = 1.18;
Clr = 1.8;
Cd=1.2;
rho_air = 1.18;
Rf = 0.3106*0.986;
Rr = 0.3109*0.986;
bb=0.59;        % brake bias

vy_filt_corr = vy_filt - r_filt*1.52;
beta = atan2(vy_filt_corr, vx_filt);

vy_front = vy_filt_corr + FRONT_LENGTH*r_filt;
vx_right = vx_filt + 0.5*TRACK*r_filt;
vx_left  = vx_filt - 0.5*TRACK*r_filt;


alpha_f = atan2(vy_front, vx_filt) - angle_filt;

load_f = M*9.8*(TOT_LENGTH-FRONT_LENGTH)/TOT_LENGTH + 0.5*Clf*rho_air.*vx_filt.^2 - h/TOT_LENGTH*ax_filt.*M;
load_r = M*9.8*FRONT_LENGTH/TOT_LENGTH              + 0.5*Clr*rho_air.*vx_filt.^2 + h/TOT_LENGTH*ax_filt.*M;

F_drag = 0.5*Cd*rho_air.*vx_filt.^2;

F_inertia_fl = ome_dot_fl_filt/Rf*0.7;
F_inertia_fr = ome_dot_fr_filt/Rf*0.7;
F_inertia_rl = ome_dot_rl_filt/Rr*0.7;
F_inertia_rr = ome_dot_rr_filt/Rr*0.7;
% 
% F_inertia_rl = 0;
% F_inertia_rr = 0;

Fx_front_dec = min(0, ax_filt*M*(bb)  /(bb*Rf+Rr-bb*Rr)*Rf+F_drag*(TOT_LENGTH-FRONT_LENGTH)/TOT_LENGTH);
Fx_rear_dec  = min(0, ax_filt*M*(1-bb)/(bb*Rf+Rr-bb*Rr)*Rr+F_drag*FRONT_LENGTH/TOT_LENGTH);
Fx_rear_acc  = max(0, ax_filt*M                           +F_drag);


Fx_front_dec = min(0, (ax_filt*M+F_drag)*(bb)  /(bb*Rf+Rr-bb*Rr)*Rf);
Fx_rear_dec  = min(0, (ax_filt*M+F_drag)*(1-bb)/(bb*Rf+Rr-bb*Rr)*Rr);
Fx_rear_acc  = max(0, (ax_filt*M+F_drag));

% Fx_r = ax_filt*M*0.5;
% Fx_r = ax_filt*M*(1-bb)+F_drag*0.5;
% Fx_r = ax_filt*M*(1-bb)/(bb*Rf+Rr-bb*Rr)*Rr+F_drag*FRONT_LENGTH/TOT_LENGTH;


Fx_fl = Fx_front_dec*0.5 + F_inertia_fl;
Fx_fr = Fx_front_dec*0.5 + F_inertia_fr;
Fx_rl = (Fx_rear_acc + Fx_rear_dec)*0.5 + F_inertia_rl;
Fx_rr = (Fx_rear_acc + Fx_rear_dec)*0.5 + F_inertia_rr;

lambda_fl = (ome_fl_filt*Rf - (vx_left .*cos(angle_filt)+vy_front.*sin(angle_filt)))./max(vx_left .*cos(angle_filt)+vy_front.*sin(angle_filt), ome_fl_filt * Rf);
lambda_fr = (ome_fr_filt*Rf - (vx_right.*cos(angle_filt)+vy_front.*sin(angle_filt)))./max(vx_right.*cos(angle_filt)+vy_front.*sin(angle_filt), ome_fr_filt * Rf);
lambda_rl = (ome_rl_filt*Rr - vx_left)./max(vx_left, ome_rl_filt * Rr);
lambda_rr = (ome_rr_filt*Rr - vx_right)./max(vx_right, ome_rr_filt * Rr);

lambda_fr(vx_filt<0.1)=nan;
lambda_fl(vx_filt<0.1)=nan;
lambda_rr(vx_filt<0.1)=nan;
lambda_rl(vx_filt<0.1)=nan;

lambda_rl(abs(ome_dot_rl_filt)>400)=nan;
lambda_rr(abs(ome_dot_rr_filt)>400)=nan;

%% analysis
valid_idx=and(abs(ay_filt)<2, vx_filt>15);
valid_idx=and(valid_idx,abs(r_filt)<0.1);
valid_idx=and(valid_idx,t>660);
valid_idx=and(valid_idx,t<1100);

% valid_idx=and(valid_idx,t>612);
% valid_idx=and(valid_idx,t<1400);
% valid_idx=and(valid_idx,brake_temp_rl_filt>400);
% valid_idx=and(valid_idx,or(s_interp'<8700,s_interp'>9100));
%abs(rad2deg(alpha_f))<0.5



%% plots
figure;
hold on
scatter(lambda_rl(valid_idx),Fx_rl(valid_idx)./(load_r(valid_idx)/2), 10, s_interp(valid_idx),"filled");
scatter(lambda_rr(valid_idx),Fx_rr(valid_idx)./(load_r(valid_idx)/2), 10, s_interp(valid_idx),"filled");
% scatter(lambda_rl(valid_idx),Fx_rl(valid_idx)./(load_r(valid_idx)/2), 10, 'r',"filled", 'DisplayName','left');
% scatter(lambda_rr(valid_idx),Fx_rr(valid_idx)./(load_r(valid_idx)/2), 10, 'b',"filled", 'DisplayName','right');
legend show;
grid on;

% ./load_r(valid_idx)

xlim([-.2 .2])
ylim([-1.5 1.5])

%%
figure;
hold on
scatter(lambda_fl(valid_idx),Fx_fl(valid_idx)./(load_f(valid_idx)/2), 10, s_interp(valid_idx),"filled");
scatter(lambda_fr(valid_idx),Fx_fr(valid_idx)./(load_f(valid_idx)/2), 10, s_interp(valid_idx),"filled");
grid on;

xlim([-.2 .2])
ylim([-1.5 1.5])
