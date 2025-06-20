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
vx=log.estimation__vx;

rho_air=1.225;
Clf=1.68;
Clr=2.23;
M=796;
b=3.115;
bf=b*463/M;
br=b-bf;
x=[0.1, 0.5*Clf*rho_air,   0.5*Clr*rho_air];
P=zeros([length(t_est),3,3]);
P(1,:,:)=diag([1e-5, 1e-4, 1e-4]);
Q=diag([1e-15, 1e-12, 1e-12]);
R=diag([1e6, 1e6]);

az_filt=lowpass(log.vectornav__raw__common__imu_accel__z,10,200);
load_fl_filt=lowpass(log.vehicle_fbk_eva__load_wheel_fl,10,100);
load_fr_filt=lowpass(log.vehicle_fbk_eva__load_wheel_fr,10,100);

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

    ax(t)=log.vectornav__raw__common__imu_accel__x(idx_vn);
    ay(t)=log.vectornav__raw__common__imu_accel__y(idx_vn);
    az(t)=-az_filt(idx_vn);
    az(t)=9.8;

    load_fl(t)=load_fl_filt(idx_vfbk)*9.8;
    load_fr(t)=load_fr_filt(idx_vfbk)*9.8;
    load_rl(t)=log.vehicle_fbk_eva__load_wheel_rl(idx_vfbk)*9.8;
    load_rr(t)=log.vehicle_fbk_eva__load_wheel_rr(idx_vfbk)*9.8;

    % predict
    x(t,:)=x(t-1,:);
    P(t,:,:)=squeeze(P(t-1,:,:))+Q;

    % correct
    if(new_meas_vfbk(t) && vx(t)>10)
        e=[(load_fl(t)+load_fr(t)-M*az(t)*br/b)-(x(t,2)*vx(t)^2-M*ax(t)*x(t,1)/b);
           (load_fl(t)+load_fr(t)-M*az(t)*bf/b)-(x(t,3)*vx(t)^2+M*ax(t)*x(t,1)/b)];
        C=[-M*ax(t)/b,  vx(t)^2,    0;
            M*ax(t)/b,  0,          vx(t)^2];
        S=C*squeeze(P(t,:,:))*C' + R;
        K=squeeze(P(t,:,:))*C'/S;
        x(t,:)=x(t,:)+(K*e)';
    end
end

new_meas_vfbk=-new_meas_vfbk;
new_meas_vn=-new_meas_vn;

Tf_est=M*az(1:end-2)*br/b+x(:,2).*vx(1:end-2).^2-M*ax(1:end-2)/b.*x(:,1);
Tf_ol=M*9.8*br/b+0.5*Clf*rho_air.*vx(1:end-2).^2-M*ax(1:end-2)/b.*0.4;


figure;
tiledlayout(3,1);
axes(1)=nexttile([2,1]);
hold on;
plot(t_est,load_fr+load_fl,'DisplayName','meas');
plot(t_est(1:end-2),Tf_est,'DisplayName','est');
plot(t_est(1:end-2),Tf_ol,'DisplayName','ol');
legend show;

axes(2)=nexttile;
hold on;
plot(t_est(1:end-2),x(:,1),'DisplayName','h');
plot(t_est(1:end-2),x(:,2),'DisplayName','Klf');
% plot(t_est(1:end-2),x(:,3),'DisplayName','Klr');
yline(0.5*Clf*rho_air,'DisplayName','Clf');
% yline(0.5*Clr*rho_air,'DisplayName','Clr');
legend show;

linkaxes(axes,'x');
