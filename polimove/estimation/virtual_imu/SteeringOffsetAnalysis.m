L=3.115;

t=log.estimation__bag_timestamp;
vx=log.estimation__vx;
delta = interp1(log.vehicle_fbk_eva__bag_timestamp,log.vehicle_fbk_eva__steering_wheel_angle,t);
yaw_rate = log.estimation__yaw_rate;
yaw_rate_to_wheel = yaw_rate *L./vx;



figure;
tiledlayout(3,1,'Padding','tight')
t1=nexttile;
hold on;
grid on;
plot(t,delta*180/pi,'DisplayName','meas');
plot(t,yaw_rate_to_wheel*180/pi,'DisplayName','imu');
legend show

t2=nexttile;
hold on;
grid on;
plot(t,yaw_rate);
yline(0.05)
yline(-0.05)

t3=nexttile;
hold on;
grid on;
plot(t,vx);

linkaxes([t1 t2 t3],'x')