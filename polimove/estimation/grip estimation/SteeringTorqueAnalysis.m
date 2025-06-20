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
t=min(log.vectornav__raw__common__header__stamp__tot):1/fs:max(log.vectornav__raw__common__header__stamp__tot);

% kistler
t_kist = double(log.kistler_msg__correvit_stamp__sec)+double(log.kistler_msg__correvit_stamp__nanosec)*1e-9 -double(log.time_offset_nsec)*1e-9;
[t_kist_uniq,idx,~] = unique(t_kist);
vx_uniq = log.kistler_msg__vel_x_corr(idx)/3.6;
vy_uniq = log.kistler_msg__vel_y_corr(idx)/3.6;
vx_interp = interp1(t_kist_uniq, vx_uniq, t, 'linear');
vy_interp = interp1(t_kist_uniq, vy_uniq, t, 'linear');
vx_interp(isnan(vx_interp)) = 0;
vy_interp(isnan(vy_interp)) = 0;

% vectornav
t_vec = log.vectornav__raw__common__header__stamp__tot;
[t_vec_uniq,idx,~] = unique(t_vec);
omez_uniq = -log.vectornav__raw__common__imu_rate__z(idx);
ax_uniq = log.vectornav__raw__common__imu_accel__x(idx);
omez_interp = interp1(t_vec_uniq, omez_uniq, t, 'linear');
ax_interp = interp1(t_vec_uniq, ax_uniq, t, 'linear');
omez_interp(isnan(omez_interp)) = 0;
ax_interp(isnan(ax_interp)) = 0;

% steer
t_steer = log.vehicle_fbk_eva__steering_fbk_stamp__tot;
[t_steer_uniq,idx,~] = unique(t_steer);
torque_uniq = log.vehicle_fbk_eva__steering_wheel_torque(idx);
torque_interp = interp1(t_steer_uniq, torque_uniq, t, 'linear');
torque_interp(isnan(torque_interp)) = 0;
angle_uniq = log.vehicle_fbk_eva__steering_wheel_angle(idx);
angle_interp = interp1(t_steer_uniq, angle_uniq, t, 'linear');
angle_interp(isnan(angle_interp)) = 0;
speed_uniq = log.vehicle_fbk_eva__steering_wheel_speed(idx);
speed_interp = interp1(t_steer_uniq, speed_uniq, t, 'linear');
speed_interp(isnan(speed_interp)) = 0;

% misc
t_traj = log.traj_server__stamp__tot;
[t_traj_uniq,idx,~] = unique(t_traj);
s_uniq = double(log.traj_server__closest_idx_ref(idx));
s_interp = interp1(t_traj_uniq, s_uniq, t, 'linear');
s_interp(isnan(s_interp)) = 0;

%% filtering
f_c = 2;
omega_c = 2 * pi * f_c;
filt_tf = tf(omega_c^2, [1 2*omega_c omega_c^2]);
filt_tf_rdot = tf(omega_c^2*[1 0], [1 2*omega_c omega_c^2]);

vx_filt = lsim(filt_tf,vx_interp,t);
vy_filt = lsim(filt_tf,vy_interp,t);
omez_filt = lsim(filt_tf,omez_interp,t);
rdot_filt = lsim(filt_tf_rdot,omez_interp,t);
torque_filt = lsim(filt_tf,torque_interp,t);
angle_filt = lsim(filt_tf,angle_interp,t);
speed_filt = lsim(filt_tf,speed_interp,t);
ax_filt = lsim(filt_tf,ax_interp,t);

%% vy correction, alpha computation
FRONT_LENGTH = 1.654;
TOT_LENGTH = 3.115;
h = 0.3;
M = 760;
Clf = 1.18;
rho_air = 1.18;


vy_filt_corr = vy_filt - omez_filt*1.52;
beta = atan2(vy_filt_corr, vx_filt);

vy_front = vy_filt_corr + FRONT_LENGTH*omez_filt;

alpha_f = atan2(vy_front, vx_filt) - angle_filt;

load_f = M*9.8*(TOT_LENGTH-FRONT_LENGTH)/TOT_LENGTH + 0.5*Clf*rho_air.*vx_filt.^2 - h/TOT_LENGTH*ax_filt.*M;


%% analysis
valid_idx=and(and(vx_filt>25, ax_filt>-3), abs(rad2deg(rdot_filt))<10);
% valid_idx=and(valid_idx,or(s_interp'<8700,s_interp'>9100));



%% plots
figure;
scatter(rad2deg(alpha_f(valid_idx)),torque_filt(valid_idx)./load_f(valid_idx), 10, speed_filt(valid_idx),"filled");
grid on;

xlim([-4 4])
ylim([-1.5 1.5])

% ./vx_filt(valid_idx)