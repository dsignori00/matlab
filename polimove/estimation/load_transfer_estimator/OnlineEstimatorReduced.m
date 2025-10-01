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
new_meas_vfbk=ones(size(t_est));
new_meas_vn=ones(size(t_est));
M=750*ones(size(t_est));
vx=log.estimation__vx;

rho_air=1.225;
Clf=1.68;
Clr=2.23;
% M=796;
b=3.115;
bf=b*463/M(1);
br=b-bf;
h=0.4;
x=[0.5*Clf*rho_air,   0.5*Clr*rho_air];
P=zeros([length(t_est),2,2]);
P(1,:,:)=diag([1e-4, 1e-4]);
Q=diag([1e-11, 1e-11]);
R=diag([1e6, 1e6]);

az_filt=lowpass(log.vectornav__raw__common__imu_accel__z,10,200);
ax_filt=lowpass(log.vectornav__raw__common__imu_accel__x,10,200);
load_fl_filt=lowpass(log.vehicle_fbk_eva__load_wheel_fl,10,100);
load_fr_filt=lowpass(log.vehicle_fbk_eva__load_wheel_fr,10,100);

vx=interp1(log.vehicle_fbk_eva__bag_timestamp,sqrt(abs(log.vehicle_fbk_eva__pitot_front_press)*100*2/1.225),log.estimation__bag_timestamp);


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
    ay(t)=log.vectornav__raw__common__imu_accel__y(idx_vn);
    az(t)=-az_filt(idx_vn);
    az(t)=9.8;

    load_fl(t)=load_fl_filt(idx_vfbk)*9.8;
    load_fr(t)=load_fr_filt(idx_vfbk)*9.8;
    load_rl(t)=log.vehicle_fbk_eva__load_wheel_rl(idx_vfbk)*9.8;
    load_rr(t)=log.vehicle_fbk_eva__load_wheel_rr(idx_vfbk)*9.8;

    M(t)=M(t)-log.vehicle_fbk_eva__fuel_used_kg(idx_vfbk);

    % predict
    x(t,:)=x(t-1,:);
    P(t,:,:)=squeeze(P(t-1,:,:))+Q;

    % correct
    if(new_meas_vfbk(t) && vx(t)>10)
        e=[(load_fl(t)+load_fr(t)-M(t)*az(t)*br/b)-(x(t,1)*vx(t)^2-M(t)*ax(t)*h/b);
           (load_rl(t)+load_rr(t)-M(t)*az(t)*bf/b)-(x(t,2)*vx(t)^2+M(t)*ax(t)*h/b)];
        C=[vx(t)^2,    0;
           0,          vx(t)^2];
        S=C*squeeze(P(t,:,:))*C' + R;
        K=squeeze(P(t,:,:))*C'/S;
        x(t,:)=x(t,:)+(K*e)';
    end
end

new_meas_vfbk=-new_meas_vfbk;
new_meas_vn=-new_meas_vn;

Tf_est=M(1:end-2).*az(1:end-2)*br/b+x(:,1).*vx(1:end-2).^2-M(1:end-2).*ax(1:end-2)/b.*h;
Tf_ol=M(1:end-2).*9.8*br/b+0.5*Clf*rho_air.*vx(1:end-2).^2-M(1:end-2).*ax(1:end-2)/b.*h;
Tf_ol_no_lt=M(1:end-2).*9.8*br/b+0.5*Clf*rho_air.*vx(1:end-2).^2;

Tr_est=M(1:end-2).*az(1:end-2)*bf/b+x(:,2).*vx(1:end-2).^2+M(1:end-2).*ax(1:end-2)/b.*h;
Tr_ol=M(1:end-2).*9.8*bf/b+0.5*Clr*rho_air.*vx(1:end-2).^2+M(1:end-2).*ax(1:end-2)/b.*h;
Tr_ol_no_lt=M(1:end-2).*9.8*bf/b+0.5*Clr*rho_air.*vx(1:end-2).^2;


%%

figure('Name','Front load');
tiledlayout(3,1,'Padding','compact');
axes(1)=nexttile([2,1]);
hold on;
plot(t_est,(load_fr+load_fl)/9.8,'DisplayName','meas');
plot(t_est(1:end-2),Tf_est/9.8,'DisplayName','est');
plot(t_est(1:end-2),Tf_ol/9.8,'DisplayName','ol');
plot(t_est(1:end-2),Tf_ol_no_lt/9.8,'DisplayName','ol_no_lt');

title('Front Load');
xlabel('t [s]');
ylabel('Load [Kg]');
grid on;
legend show;

axes(2)=nexttile;
hold on;
plot(t_est(1:end-2),x(:,1)*2/rho_air,'DisplayName','Clf_est');
yline(Clf,'DisplayName','Clf_theorical');
grid on;
legend show;


figure('Name','Rear load');
tiledlayout(3,1,'Padding','compact');
axes(3)=nexttile([2,1]);
hold on;
plot(t_est,(load_rr+load_rl)/9.8,'DisplayName','meas');
plot(t_est(1:end-2),Tr_est/9.8,'DisplayName','est');
plot(t_est(1:end-2),Tr_ol/9.8,'DisplayName','ol');
plot(t_est(1:end-2),Tr_ol_no_lt/9.8,'DisplayName','ol_no_lt');
title('Rear Load');
xlabel('t [s]');
ylabel('Load [Kg]');
grid on;
legend show;

axes(4)=nexttile;
hold on;
plot(t_est(1:end-2),x(:,2)*2/rho_air,'DisplayName','Clr_est');
yline(Clr,'DisplayName','Clr_theorical');
grid on;
legend show;


figure('Name','Total load');
tiledlayout(3,1,'Padding','compact');
axes(5)=nexttile([2,1]);
hold on;
plot(t_est,(load_fr+load_fl+load_rr+load_rl)/9.8,'DisplayName','meas');
plot(t_est(1:end-2),(Tr_est+Tf_est)/9.8,'DisplayName','est');
plot(t_est(1:end-2),(Tr_ol+Tf_ol)/9.8,'DisplayName','ol');
plot(t_est(1:end-2),(Tr_ol_no_lt+Tf_ol_no_lt)/9.8,'DisplayName','ol_no_lt');
title('Total Load');
xlabel('t [s]');
ylabel('Load [Kg]');
grid on;
legend show;

axes(6)=nexttile;
hold on;
plot(t_est(1:end-2),x(:,1)*2/rho_air,'DisplayName','Clf_est');
plot(t_est(1:end-2),x(:,2)*2/rho_air,'DisplayName','Clr_est');
yline(Clf,'DisplayName','Clf_theorical','Color','#0072BD');
yline(Clr,'DisplayName','Clr_theorical','Color','#D95319');
grid on;
legend show;

linkaxes(axes,'x');
