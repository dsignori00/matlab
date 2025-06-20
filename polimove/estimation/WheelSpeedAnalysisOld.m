clearvars -except log

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 1);

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

%% Tires params computation

% front tires
v = 0:0.1:300;
r0=306.9;
v2_coeff = (314.3-r0)/(300^2);
dyn_r = r0 + v2_coeff*v.^2;
v2_coeff_mps = v2_coeff*3.6*3.6;
figure;
hold on;grid on
plot([0, 60, 180, 300], [307.1, 307.2, 309.6, 314.3],'DisplayName','datasheet');
load_fl=0.5*1.68*1.225/2*[0, 60, 180, 300].^2/3.6/3.6; % [N] additional load
plot([0, 60, 180, 300], [307.1, 307.2, 308.3, 311.6],'DisplayName','datasheet_with_load');
plot(v,dyn_r,'DisplayName','fitted');
v2_coeff_load = (311.6-r0)/(300^2);
dyn_r_load = r0 + v2_coeff_load*v.^2;
plot(v,dyn_r-v.^2*0.00003,'DisplayName','fitted_with_load');
legend show;

%% Validation
0.5*1.225*1.68*v^2

% FL
FL_GAIN = 0.995;
r_st = r0*1e-3;
v_fl_st = log.vehicle_fbk_eva__v_fl*r_st;
r_fl_dyn = r_st + v2_coeff_mps*1e-3*(log.vehicle_fbk_eva__v_fl.*r_st).^2;
v_fl_dyn = log.vehicle_fbk_eva__v_fl .* r_fl_dyn * FL_GAIN;

% FR
FR_GAIN = 0.995;
r_st = r0*1e-3;
v_fr_st = log.vehicle_fbk_eva__v_fr*r_st;
r_fr_dyn = r_st + v2_coeff_mps*1e-3*(log.vehicle_fbk_eva__v_fr.*r_st).^2;
v_fr_dyn = log.vehicle_fbk_eva__v_fr .* r_fr_dyn * FR_GAIN;

figure;
hold on;
grid on;
plot(log.estimation__stamp__tot,log.estimation__vx,'DisplayName','est');
plot(log.vehicle_fbk_eva__stamp__tot,v_fl_dyn,'DisplayName','fl_dyn');
% plot(log.vehicle_fbk_eva__stamp__tot,v_fl_st,'DisplayName','fl_st');
plot(log.vehicle_fbk_eva__stamp__tot,v_fr_dyn,'DisplayName','fr_dyn');
% plot(log.vehicle_fbk_eva__stamp__tot,v_fr_st,'DisplayName','fr_st');
% plot(log.vehicle_fbk_eva__stamp__tot,log.vehicle_fbk_eva__v_fr*r0*1e-3,'DisplayName','fr');
legend show;

%% tir table front
figure;
hold on;

radius_60  = [307.2, 305.8, 305.3, 304.8, 304.3, 304.0, 303.6, 303.3];
radius_0   = radius_60 - 0.3;
radius_180 = [309.6, 308.3, 307.8, 307.3, 306.8, 306.5, 306.1, 305.8];
radius_300 = [314.3, 313.0, 312.5, 312.0, 311.6, 311.2, 310.9, 310.5];
v2_coeff = (radius_300-radius_0)/((300/3.6)^2);
% v2_coeff = 0.00108*ones(1,8);

for i=1:8
    scatter([0 60 180 300]./3.6, [radius_0(i) radius_60(i) radius_180(i) radius_300(i)],20,'filled');
    plot([0:0.1:(300/3.6)],radius_0(i)+v2_coeff(i)*[0:0.1:(300/3.6)].^2);
end

%% tir table rear
figure;
hold on;

radius_60  = [307.7, 306.1, 305.4, 304.8, 304.2, 303.6, 303.1, 302.6];
radius_0   = radius_60 - 0.3;
radius_180 = [310.2, 308.6, 307.9, 307.3, 306.7, 306.2, 305.7, 305.2];
radius_300 = [314.9, 313.4, 312.7, 312.1, 311.5, 311.0, 310.6, 310.1];
v2_coeff = (radius_300-radius_0)/((300/3.6)^2);
v2_coeff = 0.00110*ones(1,8);

for i=1:8
    scatter([0 60 180 300]./3.6, [radius_0(i) radius_60(i) radius_180(i) radius_300(i)],20,'filled');
    plot([0:0.1:(300/3.6)],radius_0(i)+v2_coeff(i)*[0:0.1:(300/3.6)].^2);
end

%% online computation
% front
radius_60  = [307.4 307.2, 305.8, 305.3, 304.8, 304.3, 304.0, 303.6, 303.3];
radius_0   = radius_60 - 0.3;
FL_GAIN = 1.00;
FR_GAIN = 1.00;

for i=1:length(log.vehicle_fbk_eva__v_fl)
    % FL
    load_idx = floor(log.vehicle_fbk_eva__load_wheel_fl(i)*9.81/1000)+1;
    r_inf = radius_0(load_idx)+0.00108*(log.vehicle_fbk_eva__v_fl(i)*radius_0(load_idx)*1e-3)^2;
    r_sup = radius_0(load_idx+1)+0.00108*(log.vehicle_fbk_eva__v_fl(i)*radius_0(load_idx+1)*1e-3)^2;
    r_fl(i) = r_inf + (log.vehicle_fbk_eva__load_wheel_fl(i)*9.81 - (load_idx-1)*1000)/1000*(r_sup-r_inf);
    v_fl(i) = log.vehicle_fbk_eva__v_fl(i) * r_fl(i) *1e-3 * FL_GAIN;
end

for i=1:length(log.vehicle_fbk_eva__v_fr)
    % FR
    load_idx = floor(log.vehicle_fbk_eva__load_wheel_fr(i)*9.81/1000)+1;
    r_inf = radius_0(load_idx)+0.00108*(log.vehicle_fbk_eva__v_fr(i)*radius_0(load_idx)*1e-3)^2;
    r_sup = radius_0(load_idx+1)+0.00108*(log.vehicle_fbk_eva__v_fr(i)*radius_0(load_idx+1)*1e-3)^2;
    r_fr(i) = r_inf + (log.vehicle_fbk_eva__load_wheel_fr(i)*9.81 - (load_idx-1)*1000)/1000*(r_sup-r_inf);
    v_fr(i) = log.vehicle_fbk_eva__v_fr(i) * r_fr(i) *1e-3 * FR_GAIN;
end

figure;
hold on;
plot(log.estimation__stamp__tot,log.estimation__vx,'DisplayName','est');
plot(log.vehicle_fbk_eva__stamp__tot,movmean(v_fl,[20,20]),'DisplayName','fl_dyn');
% plot(log.vehicle_fbk_eva__stamp__tot,movmean(v_fr,[20,20]),'DisplayName','fr_dyn');
legend show

% rear
radius_60  = [307.9 307.7, 306.1, 305.4, 304.8, 304.2, 303.6, 303.1, 302.6];
radius_0   = radius_60 - 0.3;

RL_GAIN = 1.00;
RR_GAIN = 1.00;

for i=1:length(log.vehicle_fbk_eva__v_rl)
    % RL
    load_idx = floor(log.vehicle_fbk_eva__load_wheel_rl(i)*9.81/1000)+1;
    r_inf = radius_0(load_idx)+0.00108*(log.vehicle_fbk_eva__v_rl(i)*radius_0(load_idx)*1e-3)^2;
    r_sup = radius_0(load_idx+1)+0.00108*(log.vehicle_fbk_eva__v_rl(i)*radius_0(load_idx+1)*1e-3)^2;
    r_rl(i) = r_inf + (log.vehicle_fbk_eva__load_wheel_rl(i)*9.81 - (load_idx-1)*1000)/1000*(r_sup-r_inf);
    v_rl(i) = log.vehicle_fbk_eva__v_rl(i) * r_rl(i) *1e-3 * RL_GAIN;
end

for i=1:length(log.vehicle_fbk_eva__v_rr)
    % RR
    load_idx = floor(log.vehicle_fbk_eva__load_wheel_rr(i)*9.81/1000)+1;
    r_inf = radius_0(load_idx)+0.00108*(log.vehicle_fbk_eva__v_rr(i)*radius_0(load_idx)*1e-3)^2;
    r_sup = radius_0(load_idx+1)+0.00108*(log.vehicle_fbk_eva__v_rr(i)*radius_0(load_idx+1)*1e-3)^2;
    r_rr(i) = r_inf + (log.vehicle_fbk_eva__load_wheel_rr(i)*9.81 - (load_idx-1)*1000)/1000*(r_sup-r_inf);
    v_rr(i) = log.vehicle_fbk_eva__v_rr(i) * r_rr(i) *1e-3 * RR_GAIN;
end

figure;
hold on;
plot(log.estimation__stamp__tot,log.estimation__vx,'DisplayName','est');
plot(log.vehicle_fbk_eva__stamp__tot,movmean(v_rl,[20, 20]),'DisplayName','rl_dyn');
plot(log.vehicle_fbk_eva__stamp__tot,movmean(v_rr,[20, 20]),'DisplayName','rr_dyn');
legend show