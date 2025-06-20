
col0 = '#0072BD';
col1 = '#D95319';
col2 = '#EDB120';
cole = '#77AC30';
coll = '#7E2F8E';
colref = '#FF00FF';

t_loc = log.estimation__stamp__tot;
vx = log.estimation__vx;

t_wheels = t_loc(log.estimation__vx_vehicle_speed_report__new_meas(:,1));
vx_wheels = log.estimation__vx_vehicle_speed_report__v(log.estimation__vx_vehicle_speed_report__new_meas(:,1),1);
vx_wheels_status = log.estimation__vx_vehicle_speed_report__unit_status__type(log.estimation__vx_vehicle_speed_report__new_meas(:,1),1);
vy_wheels = log.estimation__vy_vehicle_speed_report__v(log.estimation__vy_vehicle_speed_report__new_meas(:,1),1);
vy_wheels_status = log.estimation__vy_vehicle_speed_report__unit_status__type(log.estimation__vy_vehicle_speed_report__new_meas(:,1),1);


t_speed_sensor = t_loc(log.estimation__vx_vehicle_speed_report__new_meas(:,2));
vx_sensor = log.estimation__vx_vehicle_speed_report__v(log.estimation__vx_vehicle_speed_report__new_meas(:,2),2);
vy_sensor = log.estimation__vy_vehicle_speed_report__v(log.estimation__vy_vehicle_speed_report__new_meas(:,2),2);
vx_sensor_status = log.estimation__vx_vehicle_speed_report__unit_status__type(log.estimation__vx_vehicle_speed_report__new_meas(:,2),2);
vy_sensor_status = log.estimation__vy_vehicle_speed_report__unit_status__type(log.estimation__vy_vehicle_speed_report__new_meas(:,2),2);


t_wheels_raw = log.vehicle_fbk__wheel_speed_fbk_stamp__tot;
vx_wheels_raw = [0.985*1/3.6*log.vehicle_fbk__v_fl,...
                 0.985*1/3.6*log.vehicle_fbk__v_fr,...
                 0.992*1/3.6*log.vehicle_fbk__v_rl,...
                 0.992*1/3.6*log.vehicle_fbk__v_rr];

figure('name','Vx')

hold on;
plot(t_speed_sensor,vx_sensor,'DisplayName','sensor_vx','Color',col0);
plot(t_wheels,vx_wheels,'DisplayName','wheels_vx','Color',col1);
plot(t_loc,vx,'DisplayName','est_vx','Color',cole);
% plot(log.vehicle_fbk_eva__stamp__tot, log.vehicle_fbk_eva__v_rr*0.301);
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