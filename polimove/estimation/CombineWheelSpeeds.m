%% COMPUTATION

clearvars -except log

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

valid_wheels = zeros(length(log.estimation__stamp__tot),4);
slips = zeros(length(log.estimation__stamp__tot),4);
v_est = zeros(length(log.estimation__stamp__tot),1);
for t=1:length(log.estimation__stamp__tot)
    [valid_wheels(t,:), slips(t,:), v_est(t)] = CombineWheelSpeeds(log.estimation__ax(t), log.estimation__wheel_speeds(t,:), false, log.estimation__vx(t));
    t/length(log.estimation__stamp__tot)*100
end

%% PLOTS

figure;
hold on;
grid on;
plot(log.estimation__stamp__tot, log.estimation__vx, 'DisplayName','vx');
valid_wheel_speeds=log.estimation__wheel_speeds;
invalid_wheel_speeds=log.estimation__wheel_speeds;
for i=1:4
    valid_wheel_speeds(valid_wheels(:,i)~=1,i) = NaN;
    invalid_wheel_speeds(valid_wheels(:,i)==1,i) = NaN;
end

for i=1:4
    plot(log.estimation__stamp__tot, valid_wheel_speeds(:,i), 'DisplayName',string(i));
end
for i=1:4
    plot(log.estimation__stamp__tot, invalid_wheel_speeds(:,i),'Color',[.7 .7 .7 .3]);
end
legend show;


function [valid_wheels, slips, v_est] = CombineWheelSpeeds(ax, v_wheels, shifting, vx)

RHO_AIR = 1.225;
CONST.WHEEL_SLIP_THRS= 0.2;                   
CONST.VX_NO_SLIP_THRS= 3.0;	               
CONST.AX_SLIP_THRS= 1.75;
CONST.VX_ZERO_THRS= 0.03;
CONST.VEHICLE_AERO_CD= 1.2;
CONST.VEHICLE_MASS= 742.0;

valid_wheels = [1,1,1,1];
slips = [0,0,0,0];
if (vx > CONST.VX_NO_SLIP_THRS) 
    for i=1:4
        slips(i) = -(vx - v_wheels(i)) / vx;
    end
end

% set to zero if very very low speed
for i=1:4
    if(abs(v_wheels(i)) < CONST.VX_ZERO_THRS)
        v_wheels(i) = 0.0;
    end
end


%********* 1st wheel selection: outlier removal *********/
% compute median wheel speeds
v_wheels_sorted = sort(v_wheels);
v_median = (v_wheels_sorted(2)+v_wheels_sorted(3)) / 2;

% compute IQR
IQR = Inf;
for i=1:4
    IQR=min(IQR, abs(v_wheels(i)-v_median));
end

% // remove outliers between measures at current time
for i=1:4
    valid_wheels(i) = (abs(v_wheels(i)-v_median) <= 2.0 * IQR);
end


%********* remove rear wheels if shifting *********/
if(shifting)
    valid_wheels(3) = false;
    valid_wheels(4) = false;
end

    
%********* 2nd wheel selection: based on slip *********/
if (vx > CONST.VX_NO_SLIP_THRS)
    for i=1:4
        valid_wheels(i) = (abs(slips(i)) < CONST.WHEEL_SLIP_THRS) && valid_wheels(i);
    end
else
    % LOW SPEED - NEEDED (ALMOST) ONLY WHEN WARMING UP MOTOR
    % ONLY FRONT WHEELS
    valid_wheels(1) = true;
    valid_wheels(2) = true;
    valid_wheels(3) = false;
    valid_wheels(4) = false;

    for i=1:4
        if(abs(v_wheels(i)-vx)>0.5)
            valid_wheels(i) = false;
        end
    end
end

%********* 3rd wheel selection: based on AX (compensated) *********/
% compute compensated ax
K_DRAG = (0.5*RHO_AIR*CONST.VEHICLE_AERO_CD) / CONST.VEHICLE_MASS;
ax_comp = ax + K_DRAG * vx * vx;

% if the speed is very low do not consider accelerations
if(vx > CONST.VX_NO_SLIP_THRS)
    % braking: discard front wheels
    if(ax_comp < -CONST.AX_SLIP_THRS)
        valid_wheels(1) = false;
        valid_wheels(2) = false;
    end

    % accelerating: discard rear wheels
    if(ax_comp > CONST.AX_SLIP_THRS)
        valid_wheels(3) = false;
        valid_wheels(4) = false;
    end

    % coasting: keep all valid
end

% fill estimated velocity
v_sum = 0;
count = 0;
for i=1:4
    if(valid_wheels(i))
        v_sum = v_sum + v_wheels(i);
        count=count+1;
    end
end

if(count == 0)
    v_est = vx;
else
    v_est = v_sum / count;
end
        
        
end