clearvars -except log
% close all

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log','../../../../02_Data/');
    load(fullfile(path,file));
    log_bosch = load(fullfile(path,[file(1:end-4), '_bosch.mat'])).log.bosch__imu;
    offset_bosch = load(fullfile(path,[file(1:end-4), '_bosch.mat'])).log.time_offset_nsec;
    log.bosch__imu = log_bosch;
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
vn_ax = log.vectornav__raw__common.imu_rate__x;
vn_ay = -log.vectornav__raw__common.imu_rate__y;
vn_az = -log.vectornav__raw__common.imu_rate__z;
vn_tot = sqrt(vn_ax.^2 + vn_ay.^2 + vn_az.^2);

% Bosch
bo_t = log.bosch__imu.msg1_stamp__tot-log.time_offset_nsec*1e-9;
[bo_t,ia,ic] = unique(bo_t);
bo_ax = -log.bosch__imu.omega(ia,1)*pi/180;
bo_ay = -log.bosch__imu.omega(ia,2)*pi/180;
bo_az = log.bosch__imu.omega(ia,3)*pi/180;
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
title('Angular rates');
xlabel('Time [s]')
ylabel('\omega_x [rad/s]','Interpreter','tex')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_t,vn_ay,'DisplayName','vn');
plot(bo_t,bo_ay,'DisplayName','bosch');
legend show
xlabel('Time [s]')
ylabel('\omega_y [rad/s]','Interpreter','tex')

ax1(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_t,vn_az,'DisplayName','vn');
plot(bo_t,bo_az,'DisplayName','bosch');
legend show
xlabel('Time [s]')
ylabel('\omega_z [rad/s]','Interpreter','tex')

% ax1(f) = nexttile;
% plot(log.vehicle_fbk.bag_stamp,log.vehicle_fbk.engine_rpm);
linkaxes(ax1,'x')

%% Power spectrum
f=1;
[vn_ps_ax, vn_ps_ax_fx] = pspectrum(vn_ax,vn_t);
[vn_ps_ay, vn_ps_ax_fy] = pspectrum(vn_ay,vn_t);
[vn_ps_az, vn_ps_ax_fz] = pspectrum(vn_az,vn_t);
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
plot(bosch_ps_ax_fx, 10*log10(bosch_ps_ax),'DisplayName','bosch');
legend show
title('Power Spectrum')
xlabel('freq [Hz]');
ylabel('\omega_x Power Spectrum [dB]','Interpreter','tex');
set(gca, 'XScale', 'log');

ax2(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_ps_ax_fy, 10*log10(vn_ps_ay),'DisplayName','vn');
plot(bosch_ps_ax_fy, 10*log10(bosch_ps_ay),'DisplayName','bosch');
legend show
xlabel('freq [Hz]');
ylabel('\omega_y Power Spectrum [dB]','Interpreter','tex');
set(gca, 'XScale', 'log');

ax2(f) = nexttile;
f=f+1;
hold on;
grid on;
plot(vn_ps_ax_fz, 10*log10(vn_ps_az),'DisplayName','vn');
plot(bosch_ps_ax_fz, 10*log10(bosch_ps_az),'DisplayName','bosch');
legend show
xlabel('freq [Hz]');
ylabel('\omega_z Power Spectrum [dB]','Interpreter','tex');
set(gca, 'XScale', 'log');

linkaxes(ax2,'x')

% %% total
% [vn_ps_tot, vn_ps_ax_ft] = pspectrum(vn_tot,vn_t);
% [bosch_ps_tot, bosch_ps_ax_ft] = pspectrum(bosch_tot,bosch_t);
% [g1_ps_tot, g1_ps_ax_ft] = pspectrum(g1_tot(1:2:end),g1_t(1:2:end));
% % vn_ps_tot=abs(nufft(vn_tot,vn_t));
% % n=length(vn_t);
% % f = (0:n-1)/n;
% % figure;plot(f*200,(vn_ps_tot));
% 
% figure('name','total');
% tiledlayout(2,1,'Padding','tight');
% 
% nexttile;
% hold on;
% grid on;
% plot(vn_t, vn_tot,'DisplayName','vn');
% plot(bosch_t,  bosch_tot,'DisplayName','bosch');
% plot(g1_t,g1_tot,'DisplayName','g1');
% legend show
% title('time')
% xlabel('time [s]');
% ylabel('total acc [m/s]');
% 
% nexttile;
% hold on;
% grid on;
% plot(vn_ps_ax_ft, 10*log10(vn_ps_tot),'DisplayName','vn');
% plot(bosch_ps_ax_ft, 10*log10(bosch_ps_tot),'DisplayName','bosch');
% plot(g1_ps_ax_ft, 10*log10(g1_ps_tot),'DisplayName','g1');
% legend show
% title('Power Spectrum')
% xlabel('freq [Hz]');
% ylabel('Power Spectrum [dB]');
% set(gca, 'XScale', 'log');
% 
% %% dt comparison
% figure('Name','Dt');
% tiledlayout(2,1);
% 
% nexttile;
% hold on;
% grid on;
% plot(vn_t(1:end-1), (vn_t(2:end)-vn_t(1:end-1)),'DisplayName','vn');
% plot(bosch_t(1:end-1), (bosch_t(2:end)-bosch_t(1:end-1)),'DisplayName','bosch');
% plot(g1_t(1:end-1), (g1_t(2:end)-g1_t(1:end-1)),'DisplayName','g1');
% legend show
% 
% nexttile;
% hold on;
% grid on;
% N=50;
% histogram(vn_t(2:end)-vn_t(1:end-1),N,'Normalization','probability','DisplayName','vn')
% histogram(bosch_t(2:end)-bosch_t(1:end-1),N,'Normalization','probability','DisplayName','bosch')
% histogram(g1_t(2:end)-g1_t(1:end-1),N,'Normalization','probability','DisplayName','g1')
% legend show
% 
% %%
% % figure;
% % hold on;
% % grid on;
% % plot(vn_t(1:end-1), cumsum(vn_tot(1:end-1).*(vn_t(2:end)-vn_t(1:end-1))),'DisplayName','vn');
% % plot(bosch_t(1:end-1), cumsum(bosch_tot(1:end-1).*(bosch_t(2:end)-bosch_t(1:end-1))),'DisplayName','bosch');
% % plot(g1_t(1:end-1), cumsum(g1_tot(1:end-1).*(g1_t(2:end)-g1_t(1:end-1))),'DisplayName','g1');
% % legend show
% 
% figure('Name','Distrib');
% tiledlayout(2,1,'Padding','tight')
% 
% nexttile;
% hold on;
% grid on;
% plot(vn_ps_ax_ft, 10*log10(vn_ps_tot),'DisplayName','vn');
% plot(bosch_ps_ax_ft, 10*log10(bosch_ps_tot),'DisplayName','bosch');
% plot(g1_ps_ax_ft, 10*log10(g1_ps_tot),'DisplayName','g1');
% legend show
% title('Power Spectrum')
% xlabel('freq [Hz]');
% ylabel('Power Spectrum [dB]');
% set(gca, 'XScale', 'log');
% 
% nexttile;
% hold on
% N=20;
% histogram(vn_tot,N,'Normalization','probability','DisplayName','vn')
% histogram(bosch_tot,2*N,'Normalization','probability','DisplayName','bosch')
% histogram(g1_tot,N,'Normalization','probability','DisplayName','g1')
% xlabel('Total acceleration [m/s^2]',Interpreter='bosch')
% legend show;
% title('Measure distribution')
% grid on

% std(vn_tot)
% skewness(vn_tot);
% lowpass()
