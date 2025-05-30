clearvars -except log log_ref

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 2);

t_vfbk=log.vehicle_fbk_eva__stamp__tot;
t_est=log.estimation__stamp__tot;
t_vn=log.vectornav__raw__common__header__stamp__tot;

%%
idx_vfbk=1;
idx_vn=1;
ax=zeros(size(t_est));
ay=zeros(size(t_est));
az=zeros(size(t_est));
load_fl=zeros(size(t_est));
load_fr=zeros(size(t_est));
load_rl=zeros(size(t_est));
load_rr=zeros(size(t_est));
load=zeros(size(t_est));
new_meas_vfbk=ones(size(t_est));
new_meas_vn=ones(size(t_est));
M=750*ones(size(t_est));
vx=log.estimation__vx;

rho_air=1.225;
Clf=1.68;
Clr=2.23;

Clf=2.75;
Clr=2.75;

% M=796;
b=3.115;
bf=b*463/M(1);
br=b-bf;
h=0.35;
x=0.5*(Clf+Clr)/2*rho_air;
P=zeros([length(t_est),1]);
P(1)=1e-4;
% Q=1e-9;
Q=5e-9;
R=1;

fc = 2;
alpha = 2 * pi * fc / 200; 
b = [alpha];
a = [1, -(1 - alpha)];
ax_filt=filtfilt(b,a, log.vectornav__raw__common__imu_accel__x);
ay_filt_=filtfilt(b,a, log.vectornav__raw__common__imu_accel__y);

az_filt=lowpass(log.vectornav__raw__common__imu_accel__z,10,200);
% az_filt=movmean(log.vectornav__raw__common__imu_accel__z,[50,50]);
% ax_filt=lowpass(log.vectornav__raw__common__imu_accel__x,10,200);
% ay_filt=lowpass(log.vectornav__raw__common__imu_accel__y,10,200);

load_fl_filt=lowpass(log.vehicle_fbk_eva__load_wheel_fl,10,100);
load_fr_filt=lowpass(log.vehicle_fbk_eva__load_wheel_fr,10,100);
load_rl_filt=lowpass(log.vehicle_fbk_eva__load_wheel_rl,10,100);
load_rr_filt=lowpass(log.vehicle_fbk_eva__load_wheel_rr,10,100);

load_fl_filt_1=filtfilt(b,a,log.vehicle_fbk_eva__load_wheel_fl);


vx=interp1(log.vehicle_fbk_eva__bag_timestamp,sqrt(abs(log.vehicle_fbk_eva__pitot_front_press)*100*2/1.225),log.estimation__bag_timestamp);
s=interp1(log.traj_server__bag_timestamp,double(log.traj_server__closest_idx_ref),log.estimation__bag_timestamp);


for t=2:(length(t_est)-2)
    while(t_vfbk(idx_vfbk)<t_est(t))
        idx_vfbk=idx_vfbk+1;
        new_meas_vfbk(t)=new_meas_vfbk(t)-1;
    end
    idx_vfbk=idx_vfbk-1;
    while(t_vn(idx_vn)<t_est(t))
        idx_vn=idx_vn+1;
        new_meas_vn(t)=new_meas_vn(t)-1;
    end
    idx_vn=idx_vn-1;

    ax(t)=ax_filt(idx_vn);
    ay(t)=-ay_filt(idx_vn);
    az(t)=-az_filt(idx_vn);
    az(t)=9.8;

    load_fl(t)=load_fl_filt(idx_vfbk)*9.8;
    load_fr(t)=load_fr_filt(idx_vfbk)*9.8;
    load_rl(t)=load_rl_filt(idx_vfbk)*9.8;
    load_rr(t)=load_rr_filt(idx_vfbk)*9.8;

    load(t)=load_fl(t)+load_fr(t)+load_rl(t)+load_rr(t);

    M(t)=M(t)-log.vehicle_fbk_eva__fuel_used_kg(idx_vfbk);

    % predict
    x(t)=x(t-1);
    P(t)=P(t-1)+Q;

    % correct
    if(new_meas_vfbk(t) && vx(t)>10)
        % e=(load(t)-M(t)*az(t))-x(t)*vx(t)^2;
        e=(load(t)-M(t)*az(t))-0.5*(Clf+Clr)/2*rho_air*x(t)^2;
           
        C=2*0.5*(Clf+Clr)/2*rho_air*x(t);
        S=C*P(t)*C' + R;
        K=P(t)*C'/S;
        P(t)=(1 - K*C) * P(t);
        x(t)=x(t)+(K*e)';
    end
end

new_meas_vfbk=-new_meas_vfbk;
new_meas_vn=-new_meas_vn;

% T_est=M(1:end-2).*az(1:end-2)+x'.*vx(1:end-2).^2;
T_est=M(1:end-2).*az(1:end-2)+0.5*(Clf+Clr)/2*rho_air*(x').^2;
T_ol =M(1:end-2).*az(1:end-2)+0.5*(Clf+Clr)/2*rho_air.*vx(1:end-2).^2;



%%

% figure('Name','Front load');
% tiledlayout(3,1,'Padding','compact');
% axes(1)=nexttile([2,1]);
% hold on;
% plot(t_est,(load_fr+load_fl)/9.8,'DisplayName','meas');
% plot(t_est(1:end-2),Tf_est/9.8,'DisplayName','est');
% plot(t_est(1:end-2),Tf_ol/9.8,'DisplayName','ol');
% plot(t_est(1:end-2),Tf_ol_no_lt/9.8,'DisplayName','ol_no_lt');
% 
% title('Front Load');
% xlabel('t [s]');
% ylabel('Load [Kg]');
% grid on;
% legend show;
% 
% axes(2)=nexttile;
% hold on;
% plot(t_est(1:end-2),x(:,1)*2/rho_air,'DisplayName','Clf_est');
% yline(Clf,'DisplayName','Clf_theorical');
% grid on;
% legend show;
% 
% 
% figure('Name','Rear load');
% tiledlayout(3,1,'Padding','compact');
% axes(3)=nexttile([2,1]);
% hold on;
% plot(t_est,(load_rr+load_rl)/9.8,'DisplayName','meas');
% plot(t_est(1:end-2),Tr_est/9.8,'DisplayName','est');
% plot(t_est(1:end-2),Tr_ol/9.8,'DisplayName','ol');
% plot(t_est(1:end-2),Tr_ol_no_lt/9.8,'DisplayName','ol_no_lt');
% title('Rear Load');
% xlabel('t [s]');
% ylabel('Load [Kg]');
% grid on;
% legend show;
% 
% axes(4)=nexttile;
% hold on;
% plot(t_est(1:end-2),x(:,2)*2/rho_air,'DisplayName','Clr_est');
% yline(Clr,'DisplayName','Clr_theorical');
% grid on;
% legend show;


figure('Name','Total load');
tiledlayout(3,1,'Padding','compact');
axes(5)=nexttile([2,1]);
hold on;
plot(t_est,load/9.8,'DisplayName','meas');
plot(t_est(1:end-2),T_est/9.8,'DisplayName','est');
plot(t_est(1:end-2),T_ol/9.8,'DisplayName','ol');
title('Total Load');
xlabel('t [s]');
ylabel('Load [Kg]');
grid on;
legend show;

axes(6)=nexttile;
hold on;
% plot(t_est(1:end-2),x*2/rho_air,'DisplayName','Cl_est');
plot(t_est(1:end-2),x,'DisplayName','vw_est');
plot(t_est,vx,'DisplayName','vw_meas');
yline(Clf,'DisplayName','Clf_theorical','Color','#0072BD');
yline(Clr,'DisplayName','Clr_theorical','Color','#D95319');
grid on;
legend show;

linkaxes(axes,'x');
