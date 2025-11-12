clearvars -except log
% close all

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log','../../../../02_Data/');
    load(fullfile(path,file));
    log_bosch = load(fullfile(path,[file(1:end-4), '_bosch.mat'])).log.bosch__imu;
    offset_bosch = load(fullfile(path,[file(1:end-4), '_bosch.mat'])).log.time_offset_nsec;
    log.bosch__imu = log_bosch;
    % log.bosch__imu.bag_stamp = log.bosch__imu.bag_stamp;
end

%% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(groot,'defaultAxesTickLabelInterpreter','none');  
set(0, 'DefaultLineLineWidth', 1);

%% data conversion 
% Vectornav
vn_t = log.vectornav__raw__common.header__stamp__tot;
vn_ax = log.vectornav__raw__common.imu_accel__x;
vn_ay = -log.vectornav__raw__common.imu_accel__y;
vn_az = -log.vectornav__raw__common.imu_accel__z;
vn_tot = sqrt(vn_ax.^2 + vn_ay.^2 + vn_az.^2);

% Bosch
bo_t = log.bosch__imu.msg1_stamp__tot-log.time_offset_nsec*1e-9;
[bo_t,ia,ic] = unique(bo_t);
bo_ax = -log.bosch__imu.a(ia,1)*9.81;
bo_ay = -log.bosch__imu.a(ia,2)*9.81;
bo_az = log.bosch__imu.a(ia,3)*9.81;
bo_tot = sqrt(bo_ax.^2 + bo_ay.^2 + bo_az.^2);

%% Timeseries
f=1;
figure('Name','Time');
tiledlayout(3,1,'Padding','tight');

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_t,vn_ax,'DisplayName','vn');
plot(bo_t,bo_ax,'DisplayName','bosch');
legend show
title('Linear accelerations');
xlabel('Time [s]')
ylabel('a_x [m/s^2]','Interpreter','tex')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_t,vn_ay,'DisplayName','vn');
% plot(tex_t,tex_ay,'DisplayName','tex');
plot(bo_t,bo_ay,'DisplayName','bosch');
legend show
xlabel('Time [s]')
ylabel('a_y [m/s^2]','Interpreter','tex')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_t,vn_az,'DisplayName','vn');
% plot(tex_t,tex_az,'DisplayName','tex');
plot(bo_t,bo_az,'DisplayName','bosch');
legend show
xlabel('Time [s]')
ylabel('a_z [m/s^2]','Interpreter','tex')

% ax1(f) = nexttile;
% plot(log.vehicle_fbk.bag_stamp,log.vehicle_fbk.engine_rpm);
linkaxes(ax1,'x')

%% Power spectrum
f=1;
[vn_ps_ax, vn_ps_ax_fx] = pspectrum(vn_ax,vn_t);
[vn_ps_ay, vn_ps_ax_fy] = pspectrum(vn_ay,vn_t);
[vn_ps_az, vn_ps_ax_fz] = pspectrum(vn_az,vn_t);
% [tex_ps_ax, tex_ps_ax_fx] = pspectrum(tex_ax,tex_t);
% [tex_ps_ay, tex_ps_ax_fy] = pspectrum(tex_ay,tex_t);
% [tex_ps_az, tex_ps_ax_fz] = pspectrum(tex_az,tex_t);
[bosch_ps_ax, bosch_ps_ax_fx] = pspectrum(bo_ax,bo_t);
[bosch_ps_ay, bosch_ps_ax_fy] = pspectrum(bo_ay,bo_t);
[bosch_ps_az, bosch_ps_ax_fz] = pspectrum(bo_az,bo_t);


figure('Name','Power');
tiledlayout(3,1,'Padding','tight');

ax2(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_ps_ax_fx, 10*log10(vn_ps_ax),'DisplayName','vn');
% plot(tex_ps_ax_fx, 10*log10(tex_ps_ax),'DisplayName','tex');
plot(bosch_ps_ax_fx, 10*log10(bosch_ps_ax),'DisplayName','bosch');
% plot(bosch_ps_ax_fx, flip(10*log10(bosch_ps_ax)),'DisplayName','bosch');
legend show
title('ax')
set(gca, 'XScale', 'log');

ax2(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_ps_ax_fy, 10*log10(vn_ps_ay),'DisplayName','vn');
% plot(tex_ps_ax_fy, 10*log10(tex_ps_ay),'DisplayName','tex');
plot(bosch_ps_ax_fy, 10*log10(bosch_ps_ay),'DisplayName','bosch');
legend show
title('ay')
set(gca, 'XScale', 'log');

ax2(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_ps_ax_fz, 10*log10(vn_ps_az),'DisplayName','vn');
% plot(tex_ps_ax_fz, 10*log10(tex_ps_az),'DisplayName','tex');
plot(bosch_ps_ax_fz, 10*log10(bosch_ps_az),'DisplayName','bosch');
legend show
title('az')
set(gca, 'XScale', 'log');

linkaxes(ax2,'x')

%% total
[vn_ps_tot, vn_ps_ax_ft] = pspectrum(vn_tot,vn_t);
% [tex_ps_tot, tex_ps_ax_ft] = pspectrum(tex_tot,tex_t);
[bosch_ps_tot, bosch_ps_ax_ft] = pspectrum(bo_tot,bo_t);
% vn_ps_tot=abs(nufft(vn_tot,vn_t));
% n=length(vn_t);
% f = (0:n-1)/n;
% figure;plot(f*200,(vn_ps_tot));

figure('name','total');
tiledlayout(2,1,'Padding','tight');

nexttile;
hold on;
grid on;
plot(vn_t, vn_tot,'DisplayName','vn');
% plot(tex_t,  tex_tot,'DisplayName','tex');
plot(bo_t,bo_tot,'DisplayName','bosch');
legend show
title('time')
xlabel('time [s]');
ylabel('total acc [m/s]');

nexttile;
hold on;
grid on;
plot(vn_ps_ax_ft, 10*log10(vn_ps_tot),'DisplayName','vn');
% plot(tex_ps_ax_ft, 10*log10(tex_ps_tot),'DisplayName','tex');
plot(bosch_ps_ax_ft, 10*log10(bosch_ps_tot),'DisplayName','bosch');
legend show
title('Power Spectrum')
xlabel('freq [Hz]');
ylabel('Power Spectrum [dB]');
set(gca, 'XScale', 'log');

%% dt comparison
figure('Name','Dt');
tiledlayout(2,1);

nexttile;
hold on;
grid on;
plot(vn_t(1:end-1), (vn_t(2:end)-vn_t(1:end-1)),'DisplayName','vn');
% plot(tex_t(1:end-1), (tex_t(2:end)-tex_t(1:end-1)),'DisplayName','tex');
plot(bo_t(1:end-1), (bo_t(2:end)-bo_t(1:end-1)),'DisplayName','bosch');
legend show

nexttile;
hold on;
grid on;
N=50;
histogram(vn_t(2:end)-vn_t(1:end-1),N,'Normalization','probability','DisplayName','vn')
% histogram(tex_t(2:end)-tex_t(1:end-1),N,'Normalization','probability','DisplayName','tex')
histogram(bo_t(2:end)-bo_t(1:end-1),N,'Normalization','probability','DisplayName','bosch')
legend show

%%
% figure;
% hold on;
% grid on;
% plot(vn_t(1:end-1), cumsum(vn_tot(1:end-1).*(vn_t(2:end)-vn_t(1:end-1))),'DisplayName','vn');
% plot(tex_t(1:end-1), cumsum(tex_tot(1:end-1).*(tex_t(2:end)-tex_t(1:end-1))),'DisplayName','tex');
% plot(bosch_t(1:end-1), cumsum(bosch_tot(1:end-1).*(bosch_t(2:end)-bosch_t(1:end-1))),'DisplayName','bosch');
% legend show

figure('Name','Distrib');
tiledlayout(2,1,'Padding','tight')

nexttile;
hold on;
grid on;
plot(vn_ps_ax_ft, 10*log10(vn_ps_tot),'DisplayName','vn');
% plot(tex_ps_ax_ft, 10*log10(tex_ps_tot),'DisplayName','tex');
plot(bosch_ps_ax_ft, 10*log10(bosch_ps_tot),'DisplayName','bosch');
legend show
title('Power Spectrum')
xlabel('freq [Hz]');
ylabel('Power Spectrum [dB]');
set(gca, 'XScale', 'log');

nexttile;
hold on
N=20;
histogram(vn_tot,N,'Normalization','probability','DisplayName','vn')
% histogram(tex_tot,2*N,'Normalization','probability','DisplayName','tex')
histogram(bo_tot,N,'Normalization','probability','DisplayName','bosch')
xlabel('Total acceleration [m/s^2]',Interpreter='tex')
legend show;
title('Measure distribution')
grid on

% std(vn_tot)
% skewness(vn_tot);
% lowpass()
