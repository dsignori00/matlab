clearvars -except log log_ref

use_ref = false;

%#ok<*UNRCH>
%#ok<*INUSD>

% load track lines
load("../databases/YasMarinaSim.mat")

% addpath to extractAllFields
addpath("/home/daniele/Documents/Utils/matlab/polimove/common/utilities");

if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log','../../../02_Data/');
    load(fullfile(path,file));
end

% load log ref
if(use_ref)
    if (~exist('log_ref','var'))
        [file,path] = uigetfile('*.mat','Load log_ref');    
        tmp = load(fullfile(path,file));
        log_ref = tmp.log;
        % log_ref = old2new_mat(tmp.log);
        clearvars tmp;
    end
else
    log_ref = [];
end


%% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(groot,'defaultAxesTickLabelInterpreter','none');  
set(0, 'DefaultLineLineWidth', 2);

%% NAMING
col0 = '#0072BD';
col1 = '#D95319';
col2 = '#EDB120';
cole = '#77AC30';
coll = '#7E2F8E';
colref = '#FF00FF';

t_loc = log.estimation.stamp__tot;
x_cog = log.estimation.x_cog;
y_cog = log.estimation.y_cog;
vx = log.estimation.vx;
vy = log.estimation.vy;
heading = log.estimation.heading;

t_loc_gps0_pos = t_loc(log.estimation.gps_pos_report__new_meas(:,1));
gps0_pos_x = log.estimation.gps_pos_report__x((log.estimation.gps_pos_report__new_meas(:,1)),1);
gps0_pos_y = log.estimation.gps_pos_report__y((log.estimation.gps_pos_report__new_meas(:,1)),1);
t_loc_gps0_hd2 = t_loc(log.estimation.gps_hd2_report__new_meas(:,1));
gps0_hd2 = log.estimation.gps_hd2_report__heading((log.estimation.gps_hd2_report__new_meas(:,1)),1);

t_loc_lidar = t_loc(log.estimation.lidar_loc_report__new_meas);
lidar_pos_x = log.estimation.lidar_loc_report__x(log.estimation.lidar_loc_report__new_meas);
lidar_pos_y = log.estimation.lidar_loc_report__y(log.estimation.lidar_loc_report__new_meas);
lidar_hd = log.estimation.lidar_loc_report__yaw(log.estimation.lidar_loc_report__new_meas);


t_loc_gps1_pos = t_loc(log.estimation.gps_pos_report__new_meas(:,2));
gps1_pos_x = log.estimation.gps_pos_report__x(( log.estimation.gps_pos_report__new_meas(:,2)),2);
gps1_pos_y = log.estimation.gps_pos_report__y((log.estimation.gps_pos_report__new_meas(:,2)),2);
t_loc_gps1_hd2 = t_loc(log.estimation.gps_hd2_report__new_meas(:,2));
gps1_hd2 = log.estimation.gps_hd2_report__heading((log.estimation.gps_hd2_report__new_meas(:,2)),2);

t_loc_gps2_pos = t_loc(log.estimation.gps_pos_report__new_meas(:,3));
gps2_pos_x = log.estimation.gps_pos_report__x((log.estimation.gps_pos_report__new_meas(:,3)),3);
gps2_pos_y = log.estimation.gps_pos_report__y((log.estimation.gps_pos_report__new_meas(:,3)),3);
t_loc_gps2_hd2 = t_loc(log.estimation.gps_hd2_report__new_meas(:,3));
gps2_hd2 = log.estimation.gps_hd2_report__heading((log.estimation.gps_hd2_report__new_meas(:,3)),3);

t_wheels = t_loc(log.estimation.vx_vehicle_speed_report__new_meas(:,1));
vx_wheels = log.estimation.vx_vehicle_speed_report__v(log.estimation.vx_vehicle_speed_report__new_meas(:,1),1);
vx_wheels_status = log.estimation.vx_vehicle_speed_report__unit_status__type(log.estimation.vx_vehicle_speed_report__new_meas(:,1),1);
vy_wheels = log.estimation.vy_vehicle_speed_report__v(log.estimation.vy_vehicle_speed_report__new_meas(:,1),1);
vy_wheels_status = log.estimation.vy_vehicle_speed_report__unit_status__type(log.estimation.vy_vehicle_speed_report__new_meas(:,1),1);
vy_wheels_label = log.estimation.vy_vehicle_speed_report__visualization_label__type(log.estimation.vy_vehicle_speed_report__new_meas(:,1),1);


t_speed_sensor = t_loc(log.estimation.vx_vehicle_speed_report__new_meas(:,2));
vx_sensor = log.estimation.vx_vehicle_speed_report__v(log.estimation.vx_vehicle_speed_report__new_meas(:,2),2);
vy_sensor = log.estimation.vy_vehicle_speed_report__v(log.estimation.vy_vehicle_speed_report__new_meas(:,2),2);
vx_sensor_status = log.estimation.vx_vehicle_speed_report__unit_status__type(log.estimation.vx_vehicle_speed_report__new_meas(:,2),2);
vy_sensor_status = log.estimation.vy_vehicle_speed_report__unit_status__type(log.estimation.vy_vehicle_speed_report__new_meas(:,2),2);

% EVA
% t_wheels_raw = log.vehicle_fbk_eva.wheel_speed_fbk_stamp__tot;
% vx_wheels_raw = [0.3106*log.vehicle_fbk_eva.v_fl,...
%                  0.3106*log.vehicle_fbk_eva.v_fr,...
%                  0.3109*log.vehicle_fbk_eva.v_rl,...
%                  0.3109*log.vehicle_fbk_eva.v_rr];

% MINERVA
% t_wheels_raw = log.vehicle_fbk.wheel_speed_fbk_stamp__tot;
% vx_wheels_raw = [0.98*1/3.6*log.vehicle_fbk.v_fl,...
%                  0.98*1/3.6*log.vehicle_fbk.v_fr,...
%                  0.997*1/3.6*log.vehicle_fbk.v_rl,...
%                  0.997*1/3.6*log.vehicle_fbk.v_rr];

% ATHENA
% t_wheels_raw = log.vehicle_fbk.wheel_speed_fbk_stamp__tot;
% vx_wheels_raw = [0.963*1/3.6*log.vehicle_fbk.v_fl,...
%                  0.961*1/3.6*log.vehicle_fbk.v_fr,...
%                  0.975*1/3.6*log.vehicle_fbk.v_rl,...
%                  0.975*1/3.6*log.vehicle_fbk.v_rr];


% ref data
if(use_ref)
    t_loc_ref = log_ref.estimation.stamp__tot - double(log.time_offset_nsec-log_ref.time_offset_nsec)*1e-9;
    x_cog_ref = log_ref.estimation.x_cog;
    y_cog_ref = log_ref.estimation.y_cog;
    vx_ref = log_ref.estimation.vx;
    vy_ref = log_ref.estimation.vy;
    heading_ref = log_ref.estimation.heading;
end

% sensor label
fields=extractAllFields(log.estimation);
labels_idx=and(contains(fields, 'gps_pos_report__visualization_label__'),~contains(fields,'gc'));
labels_full = fields(labels_idx);
labels_full(find(string(labels_full) == 'gps_pos_report__visualization_label__type')) =[];
labels_full(find(string(labels_full) == 'gps_pos_report__visualization_label__TYPE__DEFAULT')) =[];
labels = erase(labels_full,'gps_pos_report__visualization_label__');
for i=1:length(labels)
    tmp = eval(strcat('log.estimation.',string(labels_full(i))));
    labels_value(i,:) = tmp(1,1);
end

%% POSITION FIGURE
figure('name', 'Pos');
tiledlayout(5,2,'Padding','compact');
f=1;

% pos X
ax(f) = nexttile([2,1]);
f=f+1;
hold on;
plot(t_loc_gps0_pos,gps0_pos_x,'.','Color',col0,'markersize',20,'DisplayName','gps0_x');
plot(t_loc_gps1_pos,gps1_pos_x,'.','Color',col1,'markersize',20,'DisplayName','gps1_x');
plot(t_loc_gps2_pos,gps2_pos_x,'.','Color',col2,'markersize',20,'DisplayName','gps2_x');
plot(t_loc_lidar,lidar_pos_x,'.','Color',coll,'markersize',20,'DisplayName','lidar_x');
plot(t_loc,x_cog,'Color',cole,'DisplayName','est_x');
if(use_ref)
    plot(t_loc_ref,x_cog_ref,'Color',colref,'DisplayName','ref_x');
end
grid on;
legend show;

% pos Y
ax(f) = nexttile([2,1]);
f=f+1;
hold on;
plot(t_loc_gps0_pos,gps0_pos_y,'.','Color',col0,'markersize',20,'DisplayName','gps0_y');
plot(t_loc_gps1_pos,gps1_pos_y,'.','Color',col1,'markersize',20,'DisplayName','gps1_y');
plot(t_loc_gps2_pos,gps2_pos_y,'.','Color',col2,'markersize',20,'DisplayName','gps2_y');
plot(t_loc_lidar,lidar_pos_y,'.','Color',coll,'markersize',20,'DisplayName','lidar_y');
plot(t_loc,y_cog,'Color',cole,'DisplayName','est_y');
if(use_ref)
    plot(t_loc_ref,y_cog_ref,'Color',colref,'DisplayName','ref_y');
end
grid on;
legend show;

% unit status
ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc_gps0_pos,log.estimation.gps_pos_report__unit_status__type(log.estimation.gps_pos_report__new_meas(:,1),1),'Color',col0,'DisplayName','gps0_status');
plot(t_loc_gps1_pos,log.estimation.gps_pos_report__unit_status__type(log.estimation.gps_pos_report__new_meas(:,2),2),'Color',col1,'DisplayName','gps1_status');
plot(t_loc_gps2_pos,log.estimation.gps_pos_report__unit_status__type(log.estimation.gps_pos_report__new_meas(:,3),3),'Color',col2,'DisplayName','gps2_status');
plot(t_loc_lidar,log.estimation.lidar_loc_report__unit_status__type(log.estimation.lidar_loc_report__new_meas),'Color',coll,'DisplayName','lidar_status');
grid on;
legend show;

% unit label
ax(f) = nexttile; 
f=f+1;
hold on;
plot(t_loc_gps0_pos,log.estimation.gps_pos_report__visualization_label__type(log.estimation.gps_pos_report__new_meas(:,1),1),'Color',col0,'DisplayName','gps0_label');
plot(t_loc_gps1_pos,log.estimation.gps_pos_report__visualization_label__type(log.estimation.gps_pos_report__new_meas(:,2),2),'Color',col1,'DisplayName','gps1_label');
plot(t_loc_gps2_pos,log.estimation.gps_pos_report__visualization_label__type(log.estimation.gps_pos_report__new_meas(:,3),3),'Color',col2,'DisplayName','gps2_label');
plot(t_loc_lidar,log.estimation.lidar_loc_report__visualization_label__type(log.estimation.lidar_loc_report__new_meas),'Color',coll,'DisplayName','lidar_label');
grid on;
legend show;
active_labels = [];
% for i=1:length(labels_value)
%     if(ismember(labels_value(i),log.estimation.gps_pos_report__visualization_label__type) || ...
%        ismember(labels_value(i),log.estimation.lidar_loc_report__visualization_label__type))
%         active_labels = [active_labels; [labels_value(i),labels(i)]];
%     end
% end
% active_labels=sortrows(active_labels);
% yticks(cell2mat(active_labels(:,1)));
% yticklabels(active_labels(:,2));

% Stdev X-Y
ax(f) = nexttile;
f=f+1;
hold on;
%plot(t_loc_gps0_pos,log.estimation.gps_pos_report__((log.estimation.gps_pos_report__new_meas(:,1)),1),'Color',col0,'DisplayName','gps0_dist');
% plot(log.vectornav__raw__gps.header__stamp__tot,log.vectornav__raw__gps.posu__y,'Color',col0,'DisplayName','gps0_stdev_x');
% plot(log.vectornav__raw__gps.header__stamp__tot,log.vectornav__raw__gps.posu__x,'Color',col1,'DisplayName','gps0_stdev_y');
% plot(t_loc_gps1,log.estimation.gps_pos_report__mah_dist((log.estimation.gps_pos_report__new_meas(:,2)),2),'Color',col1,'DisplayName','gps1_dist');
grid on;
legend show;

% Distance
ax(f) = nexttile;
f=f+1;
hold on;
gps0_dist = sqrt(log.estimation.gps_pos_report__dx(log.estimation.gps_pos_report__new_meas(:,1),1).^2+...
                 log.estimation.gps_pos_report__dy(log.estimation.gps_pos_report__new_meas(:,1),1).^2);
gps1_dist = sqrt(log.estimation.gps_pos_report__dx(log.estimation.gps_pos_report__new_meas(:,2),2).^2+...
                 log.estimation.gps_pos_report__dy(log.estimation.gps_pos_report__new_meas(:,2),2).^2);
gps2_dist = sqrt(log.estimation.gps_pos_report__dx(log.estimation.gps_pos_report__new_meas(:,3),3).^2+...
                 log.estimation.gps_pos_report__dy(log.estimation.gps_pos_report__new_meas(:,3),3).^2);
lidar_dist = sqrt(log.estimation.lidar_loc_report__dx(log.estimation.lidar_loc_report__new_meas(:,1),1).^2+...
                  log.estimation.lidar_loc_report__dy(log.estimation.lidar_loc_report__new_meas(:,1),1).^2);
% lidar_dist_ref = sqrt(log_ref.estimation.lidar_loc_report__dx(log_ref.estimation.lidar_loc_report__new_meas(:,1),1).^2+...
%                   log_ref.estimation.lidar_loc_report__dy(log_ref.estimation.lidar_loc_report__new_meas(:,1),1).^2);
plot(t_loc_gps0_pos,gps0_dist,'Color',col0,'DisplayName','gps0_dist');
plot(t_loc_gps1_pos,gps1_dist,'Color',col1,'DisplayName','gps1_dist');
plot(t_loc_gps2_pos,gps2_dist,'Color',col2,'DisplayName','gps2_dist');
plot(t_loc_lidar,lidar_dist,'Color',coll,'DisplayName','lidar_dist');
% plot(t_loc_ref(log_ref.estimation.lidar_loc_report__new_meas),lidar_dist_ref,'Color',colref,'DisplayName','lidar_dist_ref');
grid on;
legend show;

% EKF Px
ax(f) = nexttile;
f=f+1;
hold on;
yyaxis left;
plot(t_loc,log.estimation.ekf_p(:,1),'Color','#0072BD','DisplayName','ekf_P_x');
yyaxis right;
plot(t_loc,log.estimation.status__type,'Color',[0.8500 0.3250 0.0980 0.4],'DisplayName','est_status');
% yticks(0:4)
% yticklabels({'ERROR','NOT INIT','LOW QUALITY','WARNING','OK'})
grid on;
legend show;

% EKF Py
ax(f) = nexttile;
f=f+1;
hold on;
yyaxis left;
plot(t_loc,log.estimation.ekf_p(:,7),'Color','#0072BD','DisplayName','ekf_P_y');
yyaxis right;
plot(t_loc,log.estimation.status__type,'Color',[0.8500 0.3250 0.0980 0.4],'DisplayName','est_status');
grid on;
legend show;

%% SPEED VX FIGURE
figure('name','Vx')
tiledlayout(5,1,'Padding','compact');

ax(f) = nexttile([3,1]);
f=f+1;
hold on;
plot(t_speed_sensor,vx_sensor,'DisplayName','sensor_vx','Color',col0);
plot(t_wheels,vx_wheels,'DisplayName','wheels_vx','Color',col1);
plot(t_loc,vx,'DisplayName','est_vx','Color',cole);
% plot(log.vehicle_fbk_eva.stamp__tot, log.vehicle_fbk_eva.v_rr*0.301);
if(use_ref)
    plot(t_loc_ref,vx_ref,'DisplayName','ref_vx','Color',colref);
end
wheel_name=["v_fl","v_fr","v_rl","v_rr"];
wheel_col=['r','g','b','c'];
% wheel_speed_plot(4);
for i=1:4
    if(exist('vx_wheels_raw', 'var'))
        wheel_speed_plot(i)=plot(t_wheels_raw,vx_wheels_raw(:,i),'DisplayName',wheel_name(i),'Color',wheel_col(i),'LineWidth',0.5);
    end
end
grid on;
c0 = uicontrol('Style','pushbutton');
c0.Position(3)=100;
c0.Position(4)=20;
c0.String = {'Hide raw speeds'};
c0.Callback = @showHideWheelSpeeds;

if(isfield(log, 'vehicle_fbk__abs_active'))
    edges=diff(log.vehicle_fbk.abs_active);
    xregion(0,0,FaceColor="r",DisplayName="ABS ON");
    xregion(log.vehicle_fbk.stamp__tot(edges==1),log.vehicle_fbk.stamp__tot(edges==-1),FaceColor="r",HandleVisibility="off");
    xline(log.vehicle_fbk.stamp__tot(edges==1),'Color',"r",'HandleVisibility','off');
    xline(log.vehicle_fbk.stamp__tot(edges==-1),'Color',"r",'HandleVisibility','off');
end

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_speed_sensor,vx_sensor_status,'DisplayName','sensor_status','Color',col0);
plot(t_wheels,vx_wheels_status,'DisplayName','wheels_status','Color',col1);
legend show;
grid on;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc,log.estimation.ekf_p(:,13),'Color',col0,'DisplayName','ekf_P_Vx');
legend show;
grid on;

%% SLIPS LONG
figure('name','Slips Long')
tiledlayout(2,1,'Padding','compact');

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_speed_sensor,vx_sensor,'DisplayName','sensor_vx','Color',col0);
plot(t_wheels,vx_wheels,'DisplayName','wheels_vx','Color',col1);
plot(t_loc,vx,'DisplayName','est_vx','Color',cole);
% plot(log.vehicle_fbk_eva.stamp__tot, log.vehicle_fbk_eva.v_rr*0.301);
if(use_ref)
    plot(t_loc_ref,vx_ref,'DisplayName','ref_vx','Color',colref);
end
wheel_name=["v_fl","v_fr","v_rl","v_rr"];
wheel_col=['r','g','b','c'];
% wheel_speed_plot(4);
for i=1:4
    if(exist('vx_wheels_raw', 'var'))
        wheel_speed_plot(i)=plot(t_wheels_raw,vx_wheels_raw(:,i),'DisplayName',wheel_name(i),'Color',wheel_col(i),'LineWidth',0.5);
    end
end
grid on;
lgd=legend('show');
c0 = uicontrol('Style','pushbutton');
c0.Position(3)=100;
c0.Position(4)=20;
c0.String = {'Hide raw speeds'};
c0.Callback = @showHideWheelSpeeds;

if(isfield(log, 'vehicle_fbk__abs_active'))
    edges=diff(log.vehicle_fbk.abs_active);
    xregion(0,0,FaceColor="r",DisplayName="ABS ON");
    xregion(log.vehicle_fbk.stamp__tot(edges==1),log.vehicle_fbk.stamp__tot(edges==-1),FaceColor="r",HandleVisibility="off");
    xline(log.vehicle_fbk.stamp__tot(edges==1),'Color',"r",'HandleVisibility','off');
    xline(log.vehicle_fbk.stamp__tot(edges==-1),'Color',"r",'HandleVisibility','off');
end

ax(f) = nexttile;
f=f+1;
hold on;
wheel_name=["fl","fr","rl","rr"];
wheel_col=['r','g','b','c'];
for i=1:4
    plot(t_loc,log.estimation.wheel_slips(:,i),'DisplayName',wheel_name(i),'Color',wheel_col(i),'LineWidth',0.5);
end
legend show;
grid on;

%% SPEED VY FIGURE
figure('name','Vy')
tiledlayout(6,1,'Padding','compact');

ax(f) = nexttile([3,1]);
f=f+1;
hold on;
plot(t_speed_sensor,vy_sensor,'DisplayName','sensor_vy','Color',col0);
plot(t_wheels,vy_wheels,'DisplayName','wheels_vy','Color',col1);
plot(t_loc,vy,'DisplayName','est_vy','Color',cole);
if(use_ref)
    plot(t_loc_ref,vy_ref,'DisplayName','est_vy','Color',colref);
end
grid on;
legend show;
ylabel('[m/s]');

ax(f) = nexttile;
f=f+1;
hold on;
sensor_beta = rad2deg(atan(vy_sensor./vx_sensor));
sensor_beta(vx_sensor<5)=0;
plot(t_speed_sensor,sensor_beta,'DisplayName','sensor_beta','Color',col0);
wheels_beta = rad2deg(atan(vy_wheels./vx_wheels));
wheels_beta(vx_wheels<5)=0;
plot(t_wheels,wheels_beta,'DisplayName','model_beta','Color',col1);
plot(t_loc,rad2deg(log.estimation.beta),'DisplayName','est_beta','Color',cole);
ylabel('[deg]');


% steer_offset = deg2rad(-1.8);
% beta_offset_kistler = deg2rad(0.3);
% 
% steer_time = log.vehicle_fbk.steering_fbk_stamp__tot;
% steer = deg2rad(log.vehicle_fbk.steering_wheel_angle/14.625)-steer_offset;
% [steer_time_unique, ~, idx_unique] = unique(steer_time, 'stable');
% steer_unique = accumarray(idx_unique, steer, [], @mean);
% steer_interp = interp1(steer_time_unique,steer_unique,t_wheels,"nearest");
% Cf=2.6e5;
% Cr=2.2e5;
% lr = 1.77;
% lf = 1.23;
% L = lf+lr;
% m = 780;
% beta_dyn = steer_interp.*Cf.*(Cr*lr*L-lf*m.*vx_wheels.^2)./(Cf*Cr*L^2.+m.*vx_wheels.^2*(Cr*lr-Cf*lf));
% plot(t_wheels,rad2deg(beta_dyn),'DisplayName','beta_dyn','Color',col2);


legend show;
grid on;

ax(f) = nexttile;
f=f+1;
hold on;
% plot(t_speed_sensor,vy_sensor_status,'DisplayName','sensor_status','Color',col0);
% plot(t_wheels,vy_wheels_status,'DisplayName','model_status','Color',col1);
plot(t_wheels,vy_wheels_label,'DisplayName','model_label','Color',col0);

legend show;
grid on;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc,log.estimation.ekf_p(:,19),'Color',col0,'DisplayName','ekf_P_Vy');
legend show;
grid on;


%% SLIPS LAT
figure('name','Slips Lat')
tiledlayout(3,1,'Padding','compact');

ax(f) = nexttile;
f=f+1;
hold on;
grid on;
sensor_beta = rad2deg(atan(vy_sensor./vx_sensor));
sensor_beta(vx_sensor<5)=0;
plot(t_speed_sensor,sensor_beta,'DisplayName','sensor_beta','Color',col0);
wheels_beta = rad2deg(atan(vy_wheels./vx_wheels));
wheels_beta(vx_wheels<5)=0;
plot(t_wheels,wheels_beta,'DisplayName','model_beta','Color',col1);
plot(t_loc,rad2deg(log.estimation.beta),'DisplayName','est_beta','Color',cole);
if(use_ref)
    plot(t_loc_ref,rad2deg(log_ref.estimation.beta),'DisplayName','ref_beta','Color',colref);
end
ylabel('[deg]');
title('beta');
legend show;


ax(f) = nexttile;
f=f+1;
hold on;
alpha_fl = rad2deg(log.estimation.alpha(:,1));
alpha_fr = rad2deg(log.estimation.alpha(:,2));
plot(t_loc,(alpha_fl+alpha_fr)/2,'DisplayName','est_mean');
if(use_ref)
    plot(t_loc_ref,rad2deg((log_ref.estimation.alpha(:,1)+log_ref.estimation.alpha(:,2))/2),'DisplayName','ref_mean','Color',colref);
end
ylabel('[deg]');
legend show;
title('Alpha front');
grid on;

ax(f) = nexttile;
f=f+1;
hold on;
alpha_rl = rad2deg(log.estimation.alpha(:,3));
alpha_rr = rad2deg(log.estimation.alpha(:,4));
plot(t_loc,(alpha_rl+alpha_rr)/2,'DisplayName','est_mean');
if(use_ref)
    plot(t_loc_ref,rad2deg((log_ref.estimation.alpha(:,3)+log_ref.estimation.alpha(:,4))/2),'DisplayName','ref_mean','Color',colref);
end
ylabel('[deg]');
legend show;
title('Alpha rear');
grid on;

% ax(f) = nexttile;
% f=f+1;
% hold on;
% slip_fl = log.estimation.wheel_slips(:,1) * 100;
% slip_fr = log.estimation.wheel_slips(:,2) * 100;
% slip_rl = log.estimation.wheel_slips(:,3) * 100;
% slip_rr = log.estimation.wheel_slips(:,4) * 100;
% plot(t_loc,slip_fl,'DisplayName','fl');
% plot(t_loc,slip_fr,'DisplayName','fr');
% plot(t_loc,slip_rl,'DisplayName','rl');
% plot(t_loc,slip_rr,'DisplayName','rr');
% ylabel('[%]');
% legend show;
% title('Wheel slips');
% grid on;

%% HEADING FIGURE
figure('name','Heading')
tiledlayout(5,1,'Padding','compact');

ax(f) = nexttile([3,1]);
f=f+1;
hold on;
plot(t_loc_gps0_hd2,rad2deg(unwrap(wrapToPi(gps0_hd2))),'DisplayName','gps0_hd2','Color',col0);
plot(t_loc_gps1_hd2,rad2deg(unwrap(wrapToPi(gps1_hd2))),'DisplayName','gps1_hd2','Color',col1);
plot(t_loc_gps2_hd2,rad2deg(unwrap(wrapToPi(gps2_hd2))),'DisplayName','gps2_hd2','Color',col2);
% plot(log.vectornav__raw__common.header__stamp__tot, unwrap(90 - log.vectornav__raw__common.yawpitchroll__x),'DisplayName','ins_hd','Color','#00FFFF');
plot(t_loc,rad2deg(unwrap(wrapToPi(heading))),'DisplayName','est_hd','Color',cole);
plot(t_loc_lidar,rad2deg(unwrap(wrapToPi(lidar_hd))),'DisplayName','lidar_hd','Color',coll);
if(use_ref)
    plot(t_loc_ref,rad2deg(unwrap(wrapToPi(heading_ref))),'DisplayName','ref_hd','Color',colref);
end
ylabel("[deg]")
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc_gps0_hd2,log.estimation.gps_hd2_report__unit_status__type(log.estimation.gps_hd2_report__new_meas(:,1),1),'Color',col0,'DisplayName','gps0_hd2_status');
plot(t_loc_gps1_hd2,log.estimation.gps_hd2_report__unit_status__type(log.estimation.gps_hd2_report__new_meas(:,2),2),'Color',col1,'DisplayName','gps1_hd2_status');
plot(t_loc_gps2_hd2,log.estimation.gps_hd2_report__unit_status__type(log.estimation.gps_hd2_report__new_meas(:,3),3),'Color',col2,'DisplayName','gps2_hd2_status');
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc,log.estimation.ekf_p(:,25),'Color',col0,'DisplayName','ekf_P_heading');
grid on;

%% LATENCY FIGURE
figure('name','Latency')
tiledlayout(3,2,'Padding','compact');

ax(f) = nexttile;
f=f+1;
hold on;
plot(log.estimation.stamp__tot,log.estimation.gps_pos_report__latency(:,1),'DisplayName','gps0_latency');
plot(log.estimation.stamp__tot,log.estimation.gps_pos_report__latency(:,2),'DisplayName','gps1_latency');
plot(log.estimation.stamp__tot,log.estimation.gps_pos_report__latency(:,3),'DisplayName','gps2_latency');
if(use_ref)
end
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(log.estimation.stamp__tot,log.estimation.lidar_loc_report__latency,'DisplayName','lidar_latency');
if(use_ref)
end
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(log.estimation.stamp__tot,log.estimation.imu_report__latency(:,1),'DisplayName','imu0_latency');
plot(log.estimation.stamp__tot,log.estimation.imu_report__latency(:,2),'DisplayName','imu1_latency');
plot(log.estimation.stamp__tot,log.estimation.imu_report__latency(:,3),'DisplayName','imu2_latency');
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(log.estimation.stamp__tot(log.estimation.imu_report__latency(:,1)<1),log.estimation.imu_report__latency(log.estimation.imu_report__latency(:,1)<1,1),'DisplayName','imu0_latency');
plot(log.estimation.stamp__tot(log.estimation.imu_report__latency(:,2)<1),log.estimation.imu_report__latency(log.estimation.imu_report__latency(:,2)<1,2),'DisplayName','imu1_latency');
plot(log.estimation.stamp__tot(log.estimation.imu_report__latency(:,3)<1),log.estimation.imu_report__latency(log.estimation.imu_report__latency(:,3)<1,3),'DisplayName','imu2_latency');
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(log.estimation.stamp__tot,log.estimation.vx_vehicle_speed_report__latency(:,2),'DisplayName','speed_sensor_latency');
if(use_ref)
end
grid on;
legend show;

linkaxes(ax,'x')

%% MAP
fig = figure('name','MAP');

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @refreshTimeButtonPushed;
% c.Callback = @(src, event) refreshTimeButtonPushed(src, event, ax);
   

function refreshTimeButtonPushed(src,event)
    
    % Access variables from the caller workspace
    ax = evalin('caller', 'ax');
    use_ref = evalin('caller', 'use_ref');
    trajDatabase = evalin('caller', 'trajDatabase');
    col0 = evalin('caller', 'col0');
    col1 = evalin('caller', 'col1');
    col2 = evalin('caller', 'col2');
    coll = evalin('caller', 'coll');
    cole = evalin('caller', 'cole');
    colref = evalin('caller', 'colref');
    t_loc = evalin('caller', 't_loc');
    t_loc_gps0_pos = evalin('caller', 't_loc_gps0_pos');
    t_loc_gps1_pos = evalin('caller', 't_loc_gps1_pos');
    t_loc_gps2_pos = evalin('caller', 't_loc_gps2_pos');
    t_loc_lidar = evalin('caller', 't_loc_lidar');
    x_cog = evalin('caller', 'x_cog');
    y_cog = evalin('caller', 'y_cog');
    gps0_pos_x = evalin('caller', 'gps0_pos_x');
    gps0_pos_y = evalin('caller', 'gps0_pos_y');
    gps1_pos_x = evalin('caller', 'gps1_pos_x');
    gps1_pos_y = evalin('caller', 'gps1_pos_y');
    gps2_pos_x = evalin('caller', 'gps2_pos_x');
    gps2_pos_y = evalin('caller', 'gps2_pos_y');
    lidar_pos_x = evalin('caller', 'lidar_pos_x');
    lidar_pos_y = evalin('caller', 'lidar_pos_y');

    if(use_ref)
        t_loc_ref = evalin('caller', 't_loc_ref');
        x_cog_ref = evalin('caller', 'x_cog_ref');
        y_cog_ref = evalin('caller', 'y_cog_ref');
    end

    t_lim=xlim(ax(1));
    t1_gps0 = find(t_loc_gps0_pos>t_lim(1),1);
    tend_gps0 = find(t_loc_gps0_pos<t_lim(2),1,'last');
    t1_gps1 = find(t_loc_gps1_pos>t_lim(1),1);
    tend_gps1 = find(t_loc_gps1_pos<t_lim(2),1,'last');
    t1_gps2 = find(t_loc_gps2_pos>t_lim(1),1);
    tend_gps2 = find(t_loc_gps2_pos<t_lim(2),1,'last');
    t1_lidar = find(t_loc_lidar>t_lim(1),1);
    tend_lidar = find(t_loc_lidar<t_lim(2),1,'last');
    t1_est = find(t_loc>t_lim(1),1);
    tend_est = find(t_loc<t_lim(2),1,'last');
    if(use_ref)
        t1_ref = find(t_loc_ref>t_lim(1),1);
        tend_ref = find(t_loc_ref<t_lim(2),1,'last');
    end
    
    subplot(1,1,1)
    cla reset 
    title('loc accuracy')
    hold on
    grid on
    xlabel('x[m]')
    ylabel('y[m]')
    % ylim([-1000,1500])
    axis 'equal'

    % plot track lines
    id_left = length(trajDatabase) - 2;
    id_right = length(trajDatabase) - 1;
    plot(trajDatabase(id_left).X, trajDatabase(id_left).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(trajDatabase(id_right).X, trajDatabase(id_right).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
    % plot(trajDatabase(11).X, trajDatabase(11).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
            

    plot(gps0_pos_x(t1_gps0:tend_gps0), gps0_pos_y(t1_gps0:tend_gps0),'.','markersize',20,'Color',col0,'displayname','gps0');
    % gps0_pos_valid = (log.estimation.gps_pos_report__unit_status__type(log.estimation.gps_pos_report__new_meas(:,1),1) == 2);
    % plot(gps0_pos_x(gps0_pos_valid(t1_gps0:tend_gps0)), gps0_pos_y(gps0_pos_valid(t1_gps0:tend_gps0)),'.','markersize',20,'Color',col0,'displayname','gps0');
    plot(gps1_pos_x(t1_gps1:tend_gps1), gps1_pos_y(t1_gps1:tend_gps1),'.','markersize',20,'Color',col1,'displayname','gps1');
    plot(gps2_pos_x(t1_gps2:tend_gps2), gps2_pos_y(t1_gps2:tend_gps2),'.','markersize',20,'Color',col2,'displayname','gps1');
    plot(lidar_pos_x(t1_lidar:tend_lidar), lidar_pos_y(t1_lidar:tend_lidar),'.','markersize',20,'Color',coll,'displayname','lidar');

    plot(x_cog(t1_est:tend_est), y_cog(t1_est:tend_est),'Color',cole,'displayname','est');
    if(use_ref)
        plot(x_cog_ref(t1_ref:tend_ref), y_cog_ref(t1_ref:tend_ref),'Color',colref,'displayname','ref');
    end
  
    legend show
end

function showHideWheelSpeeds(src,event)
    
    wheel_speed_plot = evalin('caller', 'wheel_speed_plot');
    c0 = evalin('caller', 'c0');
    

    if(wheel_speed_plot(1).Visible=="on")
        for j=1:4
            wheel_speed_plot(j).Visible = "off";
        end
        c0.String = {'Show raw speeds'};
    else
        for j=1:4
            wheel_speed_plot(j).Visible = "on";
        end
        c0.String = {'Hide raw speeds'};
    end

end

