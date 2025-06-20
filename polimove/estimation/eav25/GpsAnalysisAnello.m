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

% Anello 1
a1_t = log.APGPS.bag_stamp;
a1_x = log.APGPS.lat;
a1_y = log.APGPS.lon;
a1_z = log.APGPS.alt_ellipsoid;
[a1_x, a1_y, ~] = geodetic2enu(a1_x, a1_y, a1_z,lat0,lon0,h0,wgs84);
a1_fix = zeros(length(log.APGPS.rtk_fix_status),1);
a1_fix(log.APGPS.rtk_fix_status==2)=1;

% Anello 2
a2_t = log.APGP2.bag_stamp;
a2_x = log.APGP2.lat;
a2_y = log.APGP2.lon;
a2_z = log.APGP2.alt_ellipsoid;
[a2_x, a2_y, ~] = geodetic2enu(a2_x, a2_y, a2_z,lat0,lon0,h0,wgs84);
a2_fix = zeros(length(log.APGP2.rtk_fix_status),1);
a2_fix(log.APGP2.rtk_fix_status==2)=1;

%% Antenna 1
f=1;
figure('Name','pos1');
tiledlayout(4,1,'Padding','tight');

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn1_t,vn1_x,'DisplayName','vn');
plot(a1_t,a1_x,'DisplayName','anello');
legend show
title('Primary Antenna')
ylabel('Lat [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn1_t,vn1_y,'DisplayName','vectornav');
plot(a1_t,a1_y,'DisplayName','anello');
legend show
ylabel('Long [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn1_t,vn1_fix,'DisplayName','vectornav');
plot(a1_t,a1_fix,'DisplayName','anello');
legend show
ylabel('RTK fix');
xlabel('Time [s]');
ylim([-0.2, 1.2]);

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
vn1_fix_interp = interp1(double(vn1_t), double(vn1_fix), double(a1_t), 'previous', 'extrap');
greater_status1 = a1_fix > vn1_fix_interp;
a1_greater = ones(length(a1_fix),1);
a1_greater(~greater_status1) = 0;
area(a1_t, a1_greater, 'DisplayName', 'anello best','EdgeColor','none');
equal1_status = a1_fix == vn1_fix_interp;
equal1 = ones(length(a1_fix),1);
equal1(~equal1_status) = 0;
area(a1_t, equal1, 'DisplayName', 'equal','EdgeColor','none');
smaller_status1 = a1_fix < vn1_fix_interp;
a1_smaller = ones(length(a1_fix),1);
a1_smaller(~smaller_status1) = 0;
area(a1_t, a1_smaller, 'DisplayName', 'vectornav best','EdgeColor','none');
ylim([-0.2, 1.2]);
legend show
xlabel('Time [s]')

linkaxes(ax1,'x')

figure('Name','piechart 1');
labels = {'anello best','equal','vectornav best'};
pie([sum(a1_greater),sum(equal1),sum(a1_smaller)]);
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
plot(a2_t,a2_x,'DisplayName','anello');
legend show
title('Secondary Antenna')
ylabel('Lat [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn2_t,vn2_y,'DisplayName','vectornav');
plot(a2_t,a2_y,'DisplayName','anello');
legend show
ylabel('Long [m]');
xlabel('Time [s]')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn2_t,vn2_fix,'DisplayName','vectornav');
plot(a2_t,a2_fix,'DisplayName','anello');
legend show
ylabel('RTK fix');
xlabel('Time [s]');
ylim([-0.2, 1.2]);

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
vn2_fix_interp = interp1(double(vn2_t), double(vn2_fix), double(a2_t), 'previous', 'extrap');
greater_status2 = a2_fix > vn2_fix_interp;
a2_greater = ones(length(a2_fix),1);
a2_greater(~greater_status2) = 0;
area(a2_t, a2_greater, 'DisplayName', 'anello best','EdgeColor','none');
equal2_status = a2_fix == vn2_fix_interp;
equal2 = ones(length(a2_fix),1);
equal2(~equal2_status) = 0;
area(a2_t, equal2, 'DisplayName', 'equal','EdgeColor','none');
smaller_status2 = a2_fix < vn2_fix_interp;
a2_smaller = ones(length(a2_fix),1);
a2_smaller(~smaller_status2) = 0;
area(a2_t, a2_smaller, 'DisplayName', 'vectornav best','EdgeColor','none');
ylim([-0.2, 1.2]);
legend show
xlabel('Time [s]')
set(gcf,'Position',[1 1 1000*1 600])

linkaxes(ax1,'x')

figure('Name','piechart 2');
labels = {'anello best','equal','vectornav best'};
pie([sum(a2_greater),sum(equal2),sum(a2_smaller)]);
legend(labels);
title('RTK fix comparison secondary antenna')
legend(labels,'Location','southeast');
set(gcf,'position',[1 1 400 400])
