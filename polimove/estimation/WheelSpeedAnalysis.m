clearvars -except log

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 2);

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

load('../../../iac/06_Scripts/GoodWood_DB/databases/Goodwood_apex_v9_3d/trajDatabase.mat');

%% data naming
col0 = '#0072BD';
col1 = '#D95319';
col2 = '#EDB120';
cole = '#77AC30';
coll = '#7E2F8E';

t_loc = log.estimation__stamp__tot;
vx = log.estimation__vx;

t_wheels = t_loc(log.estimation__vx_vehicle_speed_report__new_meas(:,1));
vx_wheels = log.estimation__vx_vehicle_speed_report__v(log.estimation__vx_vehicle_speed_report__new_meas(:,1),1);
vx_wheels_status = log.estimation__vx_vehicle_speed_report__unit_status__type(log.estimation__vx_vehicle_speed_report__new_meas(:,1),1);

t_speed_sensor = t_loc(log.estimation__vx_vehicle_speed_report__new_meas(:,2));
vx_sensor = log.estimation__vx_vehicle_speed_report__v(log.estimation__vx_vehicle_speed_report__new_meas(:,2),2);
vx_sensor_status = log.estimation__vx_vehicle_speed_report__unit_status__type(log.estimation__vx_vehicle_speed_report__new_meas(:,2),2);

% t_wheels_raw = log.vehicle_fbk__wheel_speed_fbk_stamp__tot;
% vx_wheels_raw = [1/3.6*log.vehicle_fbk__v_fl,...
%                  1/3.6*log.vehicle_fbk__v_fr,...
%                  1/3.6*log.vehicle_fbk__v_rl,...
%                  1/3.6*log.vehicle_fbk__v_rr];

t_wheels_raw = log.vehicle_fbk_eva__wheel_speed_fbk_stamp__tot;
vx_wheels_raw = [0.3106*log.vehicle_fbk_eva__v_fl,...
                 0.3106*log.vehicle_fbk_eva__v_fr,...
                 0.3109*log.vehicle_fbk_eva__v_rl,...
                 0.3109*log.vehicle_fbk_eva__v_rr];

t_wheels_proc = log.estimation__stamp__tot;
vx_wheels_proc = log.estimation__wheel_speeds*diag([1,1,1,1]);

%% open loop v
dv = log.estimation__ax.*[0;log.estimation__stamp__tot(2:end)-log.estimation__stamp__tot(1:end-1)];
v_ol(1) = 0;
for i=2:length(dv)
    v_ol(i) = v_ol(i-1) + dv(i);
end

%% plots
% figure;
% hold on;
% plot(t_speed_sensor,vx_sensor,'DisplayName','sensor_vx','Color',col0);
% plot(t_wheels,vx_wheels,'DisplayName','wheels_vx','Color',col1);
% plot(t_loc,vx,'DisplayName','est_vx','Color',cole);
% wheel_name=["v_fl","v_fr","v_rl","v_rr"];
% wheel_col=['r','g','b','c'];
% for i=1:4
%     wheel_speed_plot(i)=plot(t_wheels_raw,vx_wheels_raw(:,i),'DisplayName',wheel_name(i),'Color',wheel_col(i),'LineWidth',0.5);
% end
% plot(t_loc,v_ol,'DisplayName','ol','Color',coll);
% grid on;
% legend show;
% c0 = uicontrol('Style','pushbutton');
% c0.Position(3)=100;
% c0.Position(4)=20;
% c0.String = {'Hide raw speeds'};
% c0.Callback = @showHideWheelSpeeds;


%% NEW plots
figure;
tiledlayout(4,1,'Padding','compact');
axes(1)=nexttile([3,1]);
hold on;
% plot(t_speed_sensor,vx_sensor,'DisplayName','sensor_vx','Color',col0);
% plot(t_wheels,vx_wheels,'DisplayName','wheels_vx','Color',col1);
% plot(t_loc,vx,'DisplayName','est_vx','Color',cole);
wheel_name=["v_fl","v_fr","v_rl","v_rr"];
wheel_col=['r','g','b','c'];
for i=1:4
    % wheel_speed_plot(i)=plot(t_wheels_raw,vx_wheels_raw(:,i),'DisplayName',wheel_name(i),'Color',wheel_col(i),'LineWidth',0.8);
    wheel_speed_plot(i)=plot(t_wheels_proc,vx_wheels_proc(:,i),'DisplayName',wheel_name(i),'Color',wheel_col(i),'LineWidth',0.8,'LineStyle','-.');
end
% plot(t_loc,v_ol,'DisplayName','ol','Color',coll);
IQR=iqr(vx_wheels_proc,2);
median_value=median(vx_wheels_proc,2);
plot(t_wheels_proc,median_value+1*IQR,'DisplayName','IQR');
plot(t_wheels_proc,median_value-1*IQR,'DisplayName','IQR');
grid on;
legend show;
c0 = uicontrol('Style','pushbutton');
c0.Position(3)=100;
c0.Position(4)=20;
c0.String = {'Hide raw speeds'};
c0.Callback = @showHideWheelSpeeds;

axes(2)=nexttile;
hold on;
stdev_front=std(vx_wheels_proc(:,1:2),0,2);
stdev_rear=std(vx_wheels_proc(:,3:4),0,2);
IQR=iqr(vx_wheels_proc,2);
plot(t_wheels_proc,stdev_front,'DisplayName','stdev front');
% plot(t_wheels_proc,stdev_rear,'DisplayName','stdev rear');
grid on;


linkaxes(axes,'x');

%%
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

