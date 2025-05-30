clearvars -except log
close all

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(groot,'defaultAxesTickLabelInterpreter','none');  
set(0, 'DefaultLineLineWidth', 2);


col0 = '#0072BD';
col1 = '#D95319';
col2 = '#EDB120';
f=1;


%%%%%%%%%% SOLUTION TYPE %%%%%%%%%%
figure('Name','Pos_status')
tiledlayout(3,1);

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
yyaxis left;
plot(log.vectornav__raw__gps__bag_timestamp,log.vectornav__raw__gps__fix,'Color',col0,'LineStyle','-','DisplayName','vn');
yyaxis right;
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__pos_type__type,'Color',col1,'LineStyle','-','DisplayName','top');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__pos_type__type,'Color',col2,'LineStyle','-','DisplayName','bot');
legend show;
title('fix type');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__sol_status__status,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__sol_status__status,'Color',col2,'DisplayName','bot');
legend show;
title('sol status');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__ext_sol_stat__status,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__ext_sol_stat__status,'Color',col2,'DisplayName','bot');
legend show;
title('extended sol status');


%%%%%%%%%% EXTENDED SOLUTION STATUS %%%%%%%%%%
figure('Name','ext_sol')
tiledlayout(4,1);

binary_sol_top = dec2bin(log.novatel_top__bestgnsspos__ext_sol_stat__status);
binary_sol_top = [repmat('0', length(binary_sol_top),2), binary_sol_top];

binary_sol_bot = dec2bin(log.novatel_bottom__bestgnsspos__ext_sol_stat__status);
binary_sol_bot = [repmat('0', length(binary_sol_bot),2), binary_sol_bot];

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,bin2dec(binary_sol_top(:,8)),'Color',col1,'LineStyle','-','DisplayName','top');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,bin2dec(binary_sol_bot(:,8)),'Color',col2,'LineStyle','-','DisplayName','bot');
legend show;
title('Bit 0: RTK VERIFIED');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,bin2dec(binary_sol_top(:,5:7)),'Color',col1,'LineStyle','-','DisplayName','top');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,bin2dec(binary_sol_bot(:,5:7)),'Color',col2,'LineStyle','-','DisplayName','bot');
legend show;
title('Bit 1-3: PSEUDORANGE IONO CORRECTION');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,bin2dec(binary_sol_top(:,4)),'Color',col1,'LineStyle','-','DisplayName','top');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,bin2dec(binary_sol_bot(:,4)),'Color',col2,'LineStyle','-','DisplayName','bot');
legend show;
title('Bit 4: RTK ASSIST');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,bin2dec(binary_sol_top(:,3)),'Color',col1,'LineStyle','-','DisplayName','top');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,bin2dec(binary_sol_bot(:,3)),'Color',col2,'LineStyle','-','DisplayName','bot');
legend show;
title('Bit 5: ANTENNA');


%%%%%%%%% SATELLITES %%%%%%%%%
figure('Name','Satellites')
tiledlayout(3,1);

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__gps__bag_timestamp,log.vectornav__raw__gps__numsats,'DisplayName','numsats');
legend show;
title('Vectornav');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__num_svs,'DisplayName','num_svs');
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__num_sol_l1_svs,'DisplayName','num_sol_l1_svs');
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__num_sol_multi_svs,'DisplayName','num_sol_multi_svs');
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__num_sol_svs,'DisplayName','num_sol_svs');
legend show;
title('Novatel TOP');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__num_svs,'DisplayName','num_svs');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__num_sol_l1_svs,'DisplayName','num_sol_l1_svs');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__num_sol_multi_svs,'DisplayName','num_sol_multi_svs');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__num_sol_svs,'DisplayName','num_sol_svs');
legend show;
title('Novatel BOTTOM');



%%%%%%%%% STANDARD DEVIATIONS %%%%%%%%%
figure('Name','Stdev')
tiledlayout(3,1);

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__gps__bag_timestamp,log.vectornav__raw__gps__posu__x,'DisplayName','x');
plot(log.vectornav__raw__gps__bag_timestamp,log.vectornav__raw__gps__posu__y,'DisplayName','y');
plot(log.vectornav__raw__gps__bag_timestamp,log.vectornav__raw__gps__posu__z,'DisplayName','z');
legend show;
title('Vectornav');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__lat_stdev,'DisplayName','lat');
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__lon_stdev,'DisplayName','lon');
plot(log.novatel_top__bestgnsspos__bag_timestamp,log.novatel_top__bestgnsspos__hgt_stdev,'DisplayName','hgt');
legend show;
title('Novatel TOP');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__lat_stdev,'DisplayName','lat');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__lon_stdev,'DisplayName','lon');
plot(log.novatel_bottom__bestgnsspos__bag_timestamp,log.novatel_bottom__bestgnsspos__hgt_stdev,'DisplayName','hgt');legend show;
title('Novatel BOTTOM');



%%%%%%%%% ACCELERATIONS %%%%%%%%%
figure('Name','Acc')
tiledlayout(3,1);

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__common__bag_timestamp,log.vectornav__raw__common__imu_accel__x,'Color',col0,'DisplayName','vn');
plot(log.novatel_top__rawimu__bag_timestamp,-log.novatel_top__rawimu__linear_acceleration__y,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__rawimu__bag_timestamp,-log.novatel_bottom__rawimu__linear_acceleration__y,'Color',col2,'DisplayName','bot');
legend show;
title('Accel x');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__common__bag_timestamp,-log.vectornav__raw__common__imu_accel__y,'Color',col0,'DisplayName','vn');
plot(log.novatel_top__rawimu__bag_timestamp,-log.novatel_top__rawimu__linear_acceleration__x,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__rawimu__bag_timestamp,-log.novatel_bottom__rawimu__linear_acceleration__x,'Color',col2,'DisplayName','bot');
legend show;
title('Accel y');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__common__bag_timestamp,-log.vectornav__raw__common__imu_accel__z,'Color',col0,'DisplayName','vn');
plot(log.novatel_top__rawimu__bag_timestamp,log.novatel_top__rawimu__linear_acceleration__z,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__rawimu__bag_timestamp,log.novatel_bottom__rawimu__linear_acceleration__z,'Color',col2,'DisplayName','bot');
legend show;
title('Accel z');


%%%%%%%%% ANGULAR RATES %%%%%%%%%
figure('Name','ome')
tiledlayout(3,1);

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__common__bag_timestamp,log.vectornav__raw__common__imu_rate__x,'Color',col0,'DisplayName','vn');
plot(log.novatel_top__rawimu__bag_timestamp,-log.novatel_top__rawimu__angular_velocity__y,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__rawimu__bag_timestamp,-log.novatel_bottom__rawimu__angular_velocity__y,'Color',col2,'DisplayName','bot');
legend show;
title('Ome x');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__common__bag_timestamp,-log.vectornav__raw__common__imu_rate__y,'Color',col0,'DisplayName','vn');
plot(log.novatel_top__rawimu__bag_timestamp,-log.novatel_top__rawimu__angular_velocity__x,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__rawimu__bag_timestamp,-log.novatel_bottom__rawimu__angular_velocity__x,'Color',col2,'DisplayName','bot');
legend show;
title('Ome y');

ax(f)=nexttile;
f=f+1;
hold on;
grid on;
plot(log.vectornav__raw__common__bag_timestamp,-log.vectornav__raw__common__imu_rate__z,'Color',col0,'DisplayName','vn');
plot(log.novatel_top__rawimu__bag_timestamp,log.novatel_top__rawimu__angular_velocity__z,'Color',col1,'DisplayName','top');
plot(log.novatel_bottom__rawimu__bag_timestamp,log.novatel_bottom__rawimu__angular_velocity__z,'Color',col2,'DisplayName','bot');
legend show;
title('Ome z');

linkaxes(ax, 'x');