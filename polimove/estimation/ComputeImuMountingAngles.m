% close all;

pitch = deg2rad(15);
roll = deg2rad(2);

R=[cos(pitch), sin(pitch)*sin(roll), sin(pitch)*cos(roll);
    0          cos(roll),           -sin(roll);
   -sin(pitch),cos(pitch)*sin(roll), cos(pitch)*cos(roll)];

a_raw_vn=[log.vectornav__raw__common__imu_accel__x';
          log.vectornav__raw__common__imu_accel__y';
          log.vectornav__raw__common__imu_accel__z'];

a_proc_vn = R*a_raw_vn;

figure;
tiledlayout(3,1);
nexttile
grid on
hold on;
plot(a_raw_vn(1,:));
plot(a_proc_vn(1,:));

nexttile
grid on
hold on;
plot(a_raw_vn(2,:));
plot(a_proc_vn(2,:));

nexttile
grid on
hold on;
plot(a_raw_vn(3,:));
plot(a_proc_vn(3,:));

% figure;
% grid on;
% plot(a_raw_vn(1,:)+a_raw_vn(2,:)+a_raw_vn(3,:))

