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

%% data extraction
% t_wheels = log.vehicle_fbk__wheel_speed_fbk_stamp__tot;
% v_fl = log.vehicle_fbk__v_fl/3.6;
% v_fr = log.vehicle_fbk__v_fr/3.6;
t_wheels = log.vehicle_fbk.wheel_speed_fbk_stamp__tot;
v_fl = log.vehicle_fbk.v_fl/3.6;
v_fr = log.vehicle_fbk.v_fr/3.6;

%% analysis
[t_wheels_uniq,idx,~] = unique(t_wheels);
v_fl_uniq = v_fl(idx);
v_fl_interp = interp1(t_wheels_uniq, v_fl_uniq, log.estimation__stamp__tot, 'linear');
v_fl_interp(isnan(v_fl_interp)) = 0;
v_fr_uniq = v_fr(idx);
v_fr_interp = interp1(t_wheels_uniq, v_fr_uniq, log.estimation__stamp__tot, 'linear');
v_fr_interp(isnan(v_fr_interp)) = 0;

fs = 200;
f_c = 5;
omega_c = 2 * pi * f_c;
filt_tf = tf(omega_c^2, [1 2*omega_c omega_c^2]);
[filt_num, filt_den] = tfdata(c2d(filt_tf, 1/fs, 'tustin'), 'v');
filt_tf_deriv = tf(omega_c^2*[1 0], [1 2*omega_c omega_c^2]);
[filt_num_deriv, filt_den_deriv] = tfdata(c2d(filt_tf_deriv, 1/fs, 'tustin'), 'v');


v_fl_filt = filtfilt(filt_num, filt_den, v_fl_interp);
v_fr_filt = filtfilt(filt_num, filt_den, v_fr_interp);

%% plot training

% % athena
% g0f = 0.968;
% g2f = 1.2e-6;

% minerva
g0f = 0.9826;
g2f = 2.2e-6;

figure;
hold on;
scatter(log.estimation__vx,log.estimation__vx./v_fl_filt,10,log.estimation__ax,'filled');
scatter(log.estimation__vx,log.estimation__vx./v_fr_filt,10,log.estimation__ax,'filled');
v=0:0.1:100;
plot(v,g0f+g2f.*v.*v);
grid on
ylim([0.95 1])
colorbar

%% plot validation
figure;
hold on;
grid on;
plot(log.estimation__stamp__tot,log.estimation__vx,'DisplayName','est');
plot(t_wheels,v_fl .*(g0f+g2f.*v_fl.^2),'DisplayName','FL');
plot(t_wheels,v_fr .*(g0f+g2f.*v_fr.^2),'DisplayName','FR');
% plot(t_wheels,v_fl .* 0.965,'DisplayName','FL_2');
legend show

