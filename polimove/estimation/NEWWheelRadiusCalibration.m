clearvars -except log log_ref

%% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

%% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(groot,'defaultAxesTickLabelInterpreter','none');  
set(0, 'DefaultLineLineWidth', 2);

%% acc/dec detection
% [t_brake_unique, unique_indices] = unique(log.vehicle_fbk__brake_press_fbk_stamp__tot);
% brake_pressure_bar = interp1(t_brake_unique, log.vehicle_fbk__brake_pressure(unique_indices), log.estimation__stamp__tot, 'linear');
% is_braking = brake_pressure_bar>1;
const_speed = abs(diff(movmean(log.estimation__vx, [400 400]))) < 0.5*1e-3;
% const_speed = abs(diff(movmean(log.estimation__vx, [400 400]))) <5*1e-3;


%% vfbk speed interp
[t_vfl_unique, unique_indices] = unique(log.vehicle_fbk__wheel_speed_fbk_stamp__tot);
vfl = interp1(t_vfl_unique, log.vehicle_fbk__v_fl(unique_indices), log.estimation__stamp__tot, 'linear');
vfr = interp1(t_vfl_unique, log.vehicle_fbk__v_fr(unique_indices), log.estimation__stamp__tot, 'linear');
vrl = interp1(t_vfl_unique, log.vehicle_fbk__v_rl(unique_indices), log.estimation__stamp__tot, 'linear');
vrr = interp1(t_vfl_unique, log.vehicle_fbk__v_rr(unique_indices), log.estimation__stamp__tot, 'linear');

%% gps0

t_gps0 = log.estimation__stamp__tot;
x_gps0 = log.estimation__gps_pos_report__x(:,1);
y_gps0 = log.estimation__gps_pos_report__y(:,1);
new_meas_gps0 = log.estimation__gps_pos_report__new_meas(:,1);
status_gps0 = log.estimation__gps_pos_report__unit_status__type(:,1);

start = false;
v_gps0 = [];
v_vfbk0_f = [];
v_vfbk0_r = [];
t_start0 = [];
t_end0 = [];
dist0 = [];

for t = find(log.estimation__gps_pos_report__new_meas(:,1)==1)'

    if(~start && status_gps0(t)==2 && const_speed(t) && log.estimation__vx(t)>5)
        start_idx=t;
        start = true;
    end

    if(start && ~(status_gps0(t)==2 && const_speed(t)))
        end_idx=t-1;
        start=false;
        dist = sqrt((x_gps0(end_idx)-x_gps0(start_idx)).^2+(y_gps0(end_idx)-y_gps0(start_idx)).^2);
        dt = t_gps0(end_idx) - t_gps0(start_idx);
        v_mean_f = (mean(vfl(start_idx:end_idx))+mean(vfr(start_idx:end_idx)))/2/3.6;
        v_mean_r = (mean(vrl(start_idx:end_idx))+mean(vrr(start_idx:end_idx)))/2/3.6;
        if(dist > 50)
            v_gps0 = [v_gps0, dist./dt];
            v_vfbk0_f = [v_vfbk0_f, v_mean_f];
            v_vfbk0_r = [v_vfbk0_r, v_mean_r];
            t_start0 = [t_start0, t_gps0(start_idx)];
            t_end0 = [t_end0, t_gps0(end_idx)];
            dist0 = [dist0, dist];
        end
    end
    
end
gain0_f=(v_gps0./v_vfbk0_f)';
gain0_r=(v_gps0./v_vfbk0_r)';

%% gps1

t_gps1 = log.estimation__stamp__tot;
x_gps1 = log.estimation__gps_pos_report__x(:,2);
y_gps1 = log.estimation__gps_pos_report__y(:,2);
new_meas_gps1 = log.estimation__gps_pos_report__new_meas(:,2);
status_gps1 = log.estimation__gps_pos_report__unit_status__type(:,2);

start = false;
v_gps1 = [];
v_vfbk1_f = [];
v_vfbk1_r = [];
t_start1 = [];
t_end1 = [];
dist1 = [];

for t = find(log.estimation__gps_pos_report__new_meas(:,1)==1)'

    if(~start && status_gps1(t)==2 && const_speed(t) && log.estimation__vx(t)>5)
        start_idx=t;
        start = true;
    end

    if(start && ~(status_gps1(t)==2 && const_speed(t)))
        end_idx=t-1;
        start=false;
        dist = sqrt((x_gps1(end_idx)-x_gps1(start_idx)).^2+(y_gps1(end_idx)-y_gps1(start_idx)).^2);
        dt = t_gps1(end_idx) - t_gps1(start_idx);
        v_mean_f = (mean(vfl(start_idx:end_idx))+mean(vfr(start_idx:end_idx)))/2/3.6;
        v_mean_r = (mean(vrl(start_idx:end_idx))+mean(vrr(start_idx:end_idx)))/2/3.6;
        if(dist > 50)
            v_gps1 = [v_gps1, dist./dt];
            v_vfbk1_f = [v_vfbk1_f, v_mean_f];
            v_vfbk1_r = [v_vfbk1_r, v_mean_r];
            t_start1 = [t_start1, t_gps1(start_idx)];
            t_end1 = [t_end1, t_gps1(end_idx)];
            dist1 = [dist1, dist];
        end
    end
    
end
gain1_f=(v_gps1./v_vfbk1_f)';
gain1_r=(v_gps1./v_vfbk1_r)';


figure('Name','Data selection');
hold on
plot(t_gps0,log.estimation__vx)
xregion(t_start0,t_end0,FaceColor="b",DisplayName='gps0');
xregion(t_start1,t_end1,FaceColor="r",DisplayName='gps1');


figure('Name','front');
hold on
scatter(v_vfbk0_f,gain0_f,100,dist0,'filled','o');
scatter(v_vfbk1_f,gain1_f,100,dist1,'filled','*');
colorbar
grid on

figure('Name','rear');
hold on
scatter(v_vfbk0_r,gain0_r,100,dist0,'filled','o');
scatter(v_vfbk1_r,gain1_r,100,dist1,'filled','*');
colorbar
grid on

% figure('Name','front');
% hold on
% scatter(v_vfbk0_f,gain0_f,100,dist0,'filled','o');
% scatter(v_vfbk1_f,gain1_f,100,dist1,'filled','*');
% colorbar
% grid on

% %% TODO per ric non funziona benissimo
% 
% figure('Name','rear');
% hold on
% scatter(v_vfbk0_r,gain0_r,100,'filled','o');
% scatter(v_vfbk1_r,gain1_r,100,'filled','*');
% colorbar
% grid on
% 
% 
% figure('Name','front');
% hold on
% scatter(v_vfbk0_f,gain0_f,100,'filled','o');
% scatter(v_vfbk1_f,gain1_f,100,'filled','*');
% colorbar
% grid on
% 
% 
