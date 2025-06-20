clearvars -except loga logb

% logA proto1
if (~exist('loga','var'))
    [file,path] = uigetfile('*.mat','Load log','../../../../02_Data/');
    loga=load(fullfile(path,file)).log;
end
% logB proto2
if (~exist('logb','var'))
    [file,path] = uigetfile('*.mat','Load log','../../../../02_Data/');
    logb=load(fullfile(path,file)).log;
end

figure;
tiledlayout(3,2,'Padding','tight');


vn_totA=timeseries(sqrt(loga.vectornav__raw__common.imu_accel__x.^2+loga.vectornav__raw__common.imu_accel__y.^2+loga.vectornav__raw__common.imu_accel__z.^2),loga.vectornav__raw__common.header__stamp__tot);
vn_totB=timeseries(sqrt(logb.vectornav__raw__common.imu_accel__x.^2+logb.vectornav__raw__common.imu_accel__y.^2+logb.vectornav__raw__common.imu_accel__z.^2),logb.vectornav__raw__common.header__stamp__tot);

nexttile;
pspectrum(timetable(seconds(vn_totA.Time),vn_totA.Data),'power');
title('PROTO1');
ylim([-30 20])

nexttile;
pspectrum(timetable(seconds(vn_totB.Time),vn_totB.Data),'power');
title('PROTO2');
ylim([-30 20])


axA1=nexttile;
pspectrum(timetable(seconds(vn_totA.Time),vn_totA.Data),'spectrogram',TimeResolution=8);
title('')
caxis([-62 22])

axB1=nexttile;
pspectrum(timetable(seconds(vn_totB.Time),vn_totB.Data),'spectrogram',TimeResolution=8);
title('')
caxis([-62 22])


axA2=nexttile;
hold on;
plot(loga.vehicle_fbk.bag_stamp/60,loga.vehicle_fbk.engine_rpm/60,'DisplayName','1st Harmonic');
plot(loga.vehicle_fbk.bag_stamp/60,loga.vehicle_fbk.engine_rpm/60*2,'DisplayName','2nd Harmonic');
plot(loga.vehicle_fbk.bag_stamp/60,loga.vehicle_fbk.engine_rpm/60*3,'DisplayName','3rd Harmonic');
xlim([loga.vehicle_fbk.bag_stamp(1)/60 loga.vehicle_fbk.bag_stamp(end)/60])
ylabel('Engine Speed (Hz)')
legend('Location','northwest')
xlabel('Time (minutes)')

grid on;

axB2=nexttile;
hold on;
plot(logb.vehicle_fbk.bag_stamp/60,logb.vehicle_fbk.engine_rpm/60,'DisplayName','1st Harmonic');
plot(logb.vehicle_fbk.bag_stamp/60,logb.vehicle_fbk.engine_rpm/60*2,'DisplayName','2nd Harmonic');
plot(logb.vehicle_fbk.bag_stamp/60,logb.vehicle_fbk.engine_rpm/60*3,'DisplayName','3rd Harmonic');
xlim([logb.vehicle_fbk.bag_stamp(1)/60 logb.vehicle_fbk.bag_stamp(end)/60])
ylabel('Engine Speed (Hz)')
xlabel('Time (minutes)')
grid on;
legend('Location','northwest')
linkaxes([axA1 axA2],'x')
linkaxes([axB1 axB2],'x')

set(gcf,'Position',[1 1 1000*1.5 455*1.5])