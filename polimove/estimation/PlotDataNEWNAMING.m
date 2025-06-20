function plot_data(log, log_ref, traj_db)

use_ref = evalin("caller",'use_ref');

% style
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
gps1_pos_x = log.estimation.gps_pos_report__x((log.estimation.gps_pos_report__new_meas(:,2)),2);
gps1_pos_y = log.estimation.gps_pos_report__y((log.estimation.gps_pos_report__new_meas(:,2)),2);

t_loc_gps2_pos = t_loc(log.estimation.gps_pos_report__new_meas(:,3));
gps2_pos_x = log.estimation.gps_pos_report__x((log.estimation.gps_pos_report__new_meas(:,3)),3);
gps2_pos_y = log.estimation.gps_pos_report__y((log.estimation.gps_pos_report__new_meas(:,3)),3);

t_wheels = t_loc(log.estimation.vx_vehicle_speed_report__new_meas(:,1));
vx_wheels = log.estimation.vx_vehicle_speed_report__v(log.estimation.vx_vehicle_speed_report__new_meas(:,1),1);
vx_wheels_status = log.estimation.vx_vehicle_speed_report__unit_status__type(log.estimation.vx_vehicle_speed_report__new_meas(:,1),1);
vy_wheels = log.estimation.vy_vehicle_speed_report__v(log.estimation.vy_vehicle_speed_report__new_meas(:,1),1);
vy_wheels_status = log.estimation.vy_vehicle_speed_report__unit_status__type(log.estimation.vy_vehicle_speed_report__new_meas(:,1),1);


t_speed_sensor = t_loc(log.estimation.vx_vehicle_speed_report__new_meas(:,2));
vx_sensor = log.estimation.vx_vehicle_speed_report__v(log.estimation.vx_vehicle_speed_report__new_meas(:,2),2);
vy_sensor = log.estimation.vy_vehicle_speed_report__v(log.estimation.vy_vehicle_speed_report__new_meas(:,2),2);
vx_sensor_status = log.estimation.vx_vehicle_speed_report__unit_status__type(log.estimation.vx_vehicle_speed_report__new_meas(:,2),2);
vy_sensor_status = log.estimation.vy_vehicle_speed_report__unit_status__type(log.estimation.vy_vehicle_speed_report__new_meas(:,2),2);

% t_wheels_raw = log.vehicle_fbk_eva.wheel_speed_fbk_stamp__tot;
% vx_wheels_raw = [0.3106*log.vehicle_fbk_eva.v_fl,...
%                  0.3106*log.vehicle_fbk_eva.v_fr,...
%                  0.3109*log.vehicle_fbk_eva.v_rl,...
%                  0.3109*log.vehicle_fbk_eva.v_rr];

t_wheels_raw = log.vehicle_fbk.wheel_speed_fbk_stamp__tot;
vx_wheels_raw = [1/3.6*log.vehicle_fbk.v_fl,...
                 1/3.6*log.vehicle_fbk.v_fr,...
                 1/3.6*log.vehicle_fbk.v_rl,...
                 1/3.6*log.vehicle_fbk.v_rr];

% ref data
if(use_ref)
    t_loc_ref = log_ref.estimation__stamp__tot - double(log.time_offset_nsec-log_ref.time_offset_nsec)*1e-9;
    x_cog_ref = log_ref.estimation__x_cog;
    y_cog_ref = log_ref.estimation__y_cog;
    vx_ref = log_ref.estimation__vx;
    vy_ref = log_ref.estimation__vy;
    heading_ref = log_ref.estimation__heading;
end

% sensor label
fields=fieldnames(log.estimation);
labels_idx=contains(fields, 'gps_pos_report__visualization_label__');
labels_full = fields(labels_idx);
labels_full(find(string(labels_full) == 'gps_pos_report__visualization_label__type')) =[];
labels_full(find(string(labels_full) == 'gps_pos_report__visualization_label__TYPE__DEFAULT')) =[];
labels = erase(labels_full,'gps_pos_report__visualization_label__');
for i=1:length(labels)
    tmp = eval(strcat('log.estimation',string(labels_full(i))));
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
plot(t_loc, log.estimation.ekf_x_cog,'Color',colref);
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
active_labels = [];
for i=1:length(labels_value)
    if(ismember(labels_value(i),log.estimation.gps_pos_report__visualization_label__type) || ...
       ismember(labels_value(i),log.estimation.lidar_loc_report__visualization_label__type))
        active_labels = [active_labels; [labels_value(i),labels(i)]];
    end
end
active_labels=sortrows(active_labels);
yticks(cell2mat(active_labels(:,1)));
yticklabels(active_labels(:,2));

% Stdev X-Y
ax(f) = nexttile;
f=f+1;
hold on;
%plot(t_loc_gps0_pos,log.estimation.gps_pos_report__((log.estimation.gps_pos_report__new_meas(:,1)),1),'Color',col0,'DisplayName','gps0_dist');
plot(log.vectornav__raw__gps.header__stamp__tot,log.vectornav__raw__gps.posu__y,'Color',col0,'DisplayName','gps0_stdev_x');
plot(log.vectornav__raw__gps.header__stamp__tot,log.vectornav__raw__gps.posu__x,'Color',col1,'DisplayName','gps0_stdev_y');
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
plot(t_loc_gps0_pos,gps0_dist,'Color',col0,'DisplayName','gps0_dist');
plot(t_loc_gps1_pos,gps1_dist,'Color',col1,'DisplayName','gps1_dist');
plot(t_loc_gps2_pos,gps2_dist,'Color',col2,'DisplayName','gps2_dist');
plot(t_loc_lidar,lidar_dist,'Color',coll,'DisplayName','lidar_dist');
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
    wheel_speed_plot(i)=plot(t_wheels_raw,vx_wheels_raw(:,i),'DisplayName',wheel_name(i),'Color',wheel_col(i),'LineWidth',0.5);
end
grid on;
legend show;
c0 = uicontrol('Style','pushbutton');
c0.Position(3)=100;
c0.Position(4)=20;
c0.String = {'Hide raw speeds'};
c0.Callback = @showHideWheelSpeeds;

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

%% SPEED VY FIGURE
figure('name','Vy')
tiledlayout(6,1,'Padding','compact');

ax(f) = nexttile([3,1]);
f=f+1;
hold on;
plot(t_loc,vy,'DisplayName','est_vy','Color',cole);
plot(t_speed_sensor,vy_sensor,'DisplayName','sensor_vx','Color',col0);
plot(t_wheels,vy_wheels,'DisplayName','wheels_vx','Color',col1);
if(use_ref)
    plot(t_loc_ref,vy_ref,'DisplayName','est_vy','Color',colref);
end
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc,rad2deg(log.estimation.beta),'DisplayName','est_beta','Color',cole);
% plot(t_speed_sensor,rad2deg(atan(vy_sensor/vx_sensor)),'DisplayName','sensor_beta','Color',col0);
% plot(t_wheels,rad2deg(atan(vy_wheels/vx_wheels)),'DisplayName','wheels_beta','Color',col1);
legend show;
grid on;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_speed_sensor,vy_sensor_status,'DisplayName','sensor_status','Color',col0);
plot(t_wheels,vy_wheels_status,'DisplayName','wheels_status','Color',col1);
legend show;
grid on;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc,log.estimation.ekf_p(:,19),'Color',col0,'DisplayName','ekf_P_Vy');
legend show;
grid on;



%% HEADING FIGURE
figure('name','Heading')
tiledlayout(5,1,'Padding','compact');

ax(f) = nexttile([3,1]);
f=f+1;
hold on;
plot(t_loc_gps0_hd2,rad2deg(gps0_hd2),'DisplayName','gps0_hd','Color',col0);
plot(log.vectornav__raw__common.header__stamp__tot, unwrap(90 - log.vectornav__raw__common.yawpitchroll__x),'DisplayName','ins_hd','Color','#00FFFF');
plot(t_loc,rad2deg(heading),'DisplayName','est_hd','Color',cole);
% plot(t_loc_lidar,rad2deg(unwrap(lidar_hd)),'DisplayName','lidar_hd','Color',coll);
plot(t_loc_lidar,rad2deg((lidar_hd)),'DisplayName','lidar_hd','Color',coll);
if(use_ref)
    plot(t_loc_ref,rad2deg(heading_ref),'DisplayName','ref_hd','Color',colref);
end
% plot(log2.estimation__stamp__tot,log2.estimation__heading,'DisplayName','est_hd22','Color','#FF0000');
% plot(log_gt.estimation__stamp__tot,log_gt.estimation__heading,'Color','#4DBEEE','DisplayName','gt_hd');
grid on;
legend show;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc_gps0_hd2,log.estimation.gps_hd2_report__unit_status__type(log.estimation.gps_hd2_report__new_meas(:,1),1),'Color','#0072BD','DisplayName','ekf_P_heading');
grid on;

ax(f) = nexttile;
f=f+1;
hold on;
plot(t_loc,log.estimation.ekf_p(:,25),'Color','#0072BD','DisplayName','ekf_P_heading');
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
   

function refreshTimeButtonPushed(src,event)
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
    id_left = length(traj_db) - 2;
    id_right = length(traj_db) - 1;
    % plot(traj_db(id_left).X, traj_db(id_left).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
    % plot(traj_db(id_right).X, traj_db(id_right).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(traj_db(11).X, traj_db(11).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
            

    plot(gps0_pos_x(t1_gps0:tend_gps0), gps0_pos_y(t1_gps0:tend_gps0),'.','markersize',20,'Color',col0,'displayname','gps0');
    plot(gps1_pos_x(t1_gps1:tend_gps1), gps1_pos_y(t1_gps1:tend_gps1),'.','markersize',20,'Color',col1,'displayname','gps1');
    plot(gps2_pos_x(t1_gps2:tend_gps2), gps2_pos_y(t1_gps2:tend_gps2),'.','markersize',20,'Color',col2,'displayname','gps1');
    plot(lidar_pos_x(t1_lidar:tend_lidar), lidar_pos_y(t1_lidar:tend_lidar),'.','markersize',20,'Color',coll,'displayname','lidar');

    plot(x_cog(t1_est:tend_est), y_cog(t1_est:tend_est),'Color',cole,'displayname','est');
    if(use_ref)
        plot(x_cog_ref(t1_ref:tend_ref), y_cog_ref(t1_ref:tend_ref),'Color',colref,'displayname','ref');
    end
  

end

function showHideWheelSpeeds(src,event)
    
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

end