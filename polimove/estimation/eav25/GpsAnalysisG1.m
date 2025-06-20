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

lat0=24.47023420 + 0.0000113;
lon0=54.60517690 + 0.0000014;
h0=4;
wgs84 = wgs84Ellipsoid;

%% data conversion
% Vectornav 1
vn1_t = log.vectornav__raw__gps.header__stamp__tot;
[vn1_x, vn1_y, ~] = geodetic2enu(log.vectornav__raw__gps.poslla__x, log.vectornav__raw__gps.poslla__y, log.vectornav__raw__gps.poslla__z,lat0,lon0,h0,wgs84);
vn1_fix = zeros(length(log.vectornav__raw__gps.fix),1);
vn1_fix(log.vectornav__raw__gps.fix==8) =  1;

% Vectornav 2
vn2_t = log.vectornav__raw__gps2.header__stamp__tot;
vn2_x = log.vectornav__raw__gps2.poslla__x;
vn2_x(vn2_x<1)=nan;
vn2_y = log.vectornav__raw__gps2.poslla__y;
vn2_y(vn2_y<1)=nan;
vn2_z = log.vectornav__raw__gps2.poslla__z;
[vn2_x, vn2_y, ~] = geodetic2enu(vn2_x, vn2_y, vn2_z,lat0,lon0,h0,wgs84);
vn2_fix = zeros(length(log.vectornav__raw__gps2.fix),1);
vn2_fix(min(double(log.vectornav__raw__gps2.fix),interp1(vn1_t,double(log.vectornav__raw__gps.fix),vn2_t,"nearest"))==8) =  1;


% G1-pro 1
g1_t = log.g1pro__gnss_ant_front.header__stamp__tot;
g1_x = log.g1pro__gnss_ant_front.latitude;
g1_x(g1_x<1)=nan;
g1_y = log.g1pro__gnss_ant_front.longitude;
g1_y(g1_x<1)=nan;
g1_z = log.g1pro__gnss_ant_front.height;
g1_z(g1_x<1)=nan;
[g1_x, g1_y, ~] = geodetic2enu(g1_x, g1_y, g1_z,lat0,lon0,h0,wgs84);
g1_fix = zeros(length(log.g1pro__gnss_ant_front.mode),1);
g1_fix(log.g1pro__gnss_ant_front.mode==4)=1;

% G1-pro 2
g2_t = log.g1pro__gnss_ant_rear.header__stamp__tot;
g2_x = log.g1pro__gnss_ant_rear.latitude;
g2_x(g2_x<1)=nan;
g2_y = log.g1pro__gnss_ant_rear.longitude;
g2_y(g2_x<1)=nan;
g2_z = log.g1pro__gnss_ant_rear.height;
g2_z(g2_x<1)=nan;
[g2_x, g2_y, ~] = geodetic2enu(g2_x, g2_y, g2_z,lat0,lon0,h0,wgs84);
g2_fix = zeros(length(log.g1pro__gnss_ant_rear.mode),1);
g2_fix(log.g1pro__gnss_ant_rear.mode==4)=1;

%% Antenna 1
f=1;
figure('Name','pos1');
tiledlayout(4,1,'Padding','tight');

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn1_t,vn1_x,'DisplayName','vectornav');
plot(g1_t,g1_x,'DisplayName','g1-pro');
legend show
title('Primary Antenna')
ylabel('Lat [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn1_t,vn1_y,'DisplayName','vectornav');
plot(g1_t,g1_y,'DisplayName','g1-pro');
legend show
ylabel('Long [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn1_t,vn1_fix,'DisplayName','vectornav');
plot(g1_t,g1_fix,'DisplayName','g1-pro');
legend show
ylabel('RTK fix');
xlabel('Time [s]');
ylim([-0.2, 1.2]);

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
vn1_fix_interp = interp1(double(vn1_t), double(vn1_fix), double(g1_t), 'previous', 'extrap');
greater_status1 = g1_fix > vn1_fix_interp;
g1_greater = ones(length(g1_fix),1);
g1_greater(~greater_status1) = 0;
area(g1_t, g1_greater, 'DisplayName', 'g1-pro best','EdgeColor','none');
equal1_status = g1_fix == vn1_fix_interp;
equal1 = ones(length(g1_fix),1);
equal1(~equal1_status) = 0;
area(g1_t, equal1, 'DisplayName', 'equal','EdgeColor','none');
smaller_status1 = g1_fix < vn1_fix_interp;
g1_smaller = ones(length(g1_fix),1);
g1_smaller(~smaller_status1) = 0;
area(g1_t, g1_smaller, 'DisplayName', 'vectornav best','EdgeColor','none');
ylim([-0.2, 1.2]);
legend show
title('fix comparison')

linkaxes(ax1,'x')

figure('Name','piechart 1');
labels = {'g1-pro best','equal','vectornav best'};
pie([sum(g1_greater),sum(equal1),sum(g1_smaller)]);
title('RTK fix comparison primary antenna')
legend(labels,'Location','southeast');
set(gcf,'position',[1 1 400 400])

%% Antenna 2
f=1;
figure('Name','pos2');
tiledlayout(4,1,'Padding','tight');

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn2_t,vn2_x,'DisplayName','vectornav');
plot(g2_t,g2_x,'DisplayName','g1-pro');
legend show
title('Secondary Antenna')
ylabel('Lat [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn2_t,vn2_y,'DisplayName','vectornav');
plot(g2_t,g2_y,'DisplayName','g1-pro');
legend show
ylabel('Long [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn2_t,vn2_fix,'DisplayName','vectornav');
plot(g2_t,g2_fix,'DisplayName','g1-pro');
legend show
ylabel('RTK fix');
xlabel('Time [s]');
ylim([-0.2, 1.2]);

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
vn2_fix_interp = interp1(double(vn2_t), double(vn2_fix), double(g2_t), 'previous', 'extrap');
greater_status2 = g2_fix > vn2_fix_interp;
g2_greater = ones(length(g2_fix),1);
g2_greater(~greater_status2) = 0;
area(g2_t, g2_greater, 'DisplayName', 'g2 > vn2','EdgeColor','none');
equal2_status = g2_fix == vn2_fix_interp;
equal2 = ones(length(g2_fix),1);
equal2(~equal2_status) = 0;
area(g2_t, equal2, 'DisplayName', 'g2 = vn2','EdgeColor','none');
smaller_status2 = g2_fix < vn2_fix_interp;
g2_smaller = ones(length(g2_fix),1);
g2_smaller(~smaller_status2) = 0;
area(g2_t, g2_smaller, 'DisplayName', 'g2 < vn2','EdgeColor','none');
ylim([-0.2, 1.2]);
legend show
xlabel('Time [s]')
set(gcf,'Position',[1 1 1000*1 600])

linkaxes(ax1,'x')

figure('Name','piechart 2');
labels = {'g1-pro best','equal','vectornav best'};
pie([sum(g2_greater),sum(equal2),sum(g2_smaller)]);
title('RTK fix comparison secondary antenna')
legend(labels,'Location','southeast');
set(gcf,'position',[1 1 400 400])

