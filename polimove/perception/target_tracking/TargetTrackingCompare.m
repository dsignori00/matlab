close all
clearvars -except log log_2 log_3 log_ref

%#ok<*UNRCH>
%#ok<*INUSD>
%#ok<*NASGU>

use_log2         = true;
use_log3         = false;
use_sim_ref      = false;
use_ref          = false;
compute_err_std  = false;

%% Paths

addpath("../../01_Tools/00_GlobalFunctions/personal/")
addpath("../../01_Tools/00_GlobalFunctions/utilities/")
addpath("../../01_Tools/00_GlobalFunctions/constants/")
addpath("../../01_Tools/00_GlobalFunctions/plot/")
%% Load data

normal_path = "/home/daniele/Documents/PoliMOVE/04_Bags/";
normal_path = char(normal_path);

% Load log
if ~exist('log', 'var')
    [file, path] = uigetfile(fullfile(normal_path, '*.mat'), 'Load log', normal_path);
    normal_path = path;
    if isequal(file, 0)  
        disp('User canceled file selection.');
    else
        load(fullfile(path, file));
    end
end
name1 = 'develop';


% load log 2
if(use_log2)
    if (~exist('log_2','var'))
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log_2');
        if isequal(file, 0)  
        disp('User canceled file selection.');
        else
        tmp = load(fullfile(path,file));
        log_2 = tmp.log;
        clearvars tmp;
        end
    end
    name2 = 'imm disabled';
end


% load log 3
if(use_log3)
    if (~exist('log_3','var'))
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log_3');
        tmp = load(fullfile(path,file));
        log_3 = tmp.log;
        clearvars tmp;
    end
    name3 = 'ctrv4';
end

% load sim ref
if(use_sim_ref)
    if (~exist('log_ref','var') & ~use_sim_ref)
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log_ref');
        tmp = load(fullfile(path,file));
        log_ref = tmp.log;
        clearvars tmp;
    end
end

% load log ref
if(use_ref)
    if (~exist('log_ref','var'))
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load ground truth');
        tmp = load(fullfile(path,file));
        log_ref = tmp.log;
        clearvars tmp;
    end
end

DateTime = datetime(log.time_offset_nsec,'ConvertFrom','epochtime','TicksPerSecond',1e9,'Format','dd-MMM-yyyy HH:mm:ss');

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 2);

col.tt1 = 'blue';
col.tt2 = 'red';
col.tt3 = 'green';
col.ref = 'black';


%% Load data

% TARGET TRACKING MAIN
    tt_stamp = log.perception__opponents.stamp__tot;
    % relative
    tt_x_rel = log.perception__opponents.opponents__x_rel;
    tt_y_rel = log.perception__opponents.opponents__y_rel;
    tt_x_rel(tt_x_rel==0)=nan;
    tt_y_rel(tt_y_rel==0)=nan;
    tt_rho_dot = log.perception__opponents.opponents__rho_dot;
    tt_rho_dot(tt_rho_dot==0)=nan;
    tt_yaw_rel = log.perception__opponents.opponents__psi_rel;
    tt_yaw_rel(tt_yaw_rel==0)=nan;
    % map
    tt_x_map = log.perception__opponents.opponents__x_geom;
    tt_y_map = log.perception__opponents.opponents__y_geom;
    tt_x_map(tt_x_map==0)=nan;
    tt_y_map(tt_y_map==0)=nan;
    tt_vx = log.perception__opponents.opponents__vx;
    tt_vx(tt_vx==0)=nan;
    tt_ax = log.perception__opponents.opponents__ax;
    tt_ax(tt_ax==0)=nan;
    tt_yaw_map = log.perception__opponents.opponents__psi;
    tt_yaw_map(tt_yaw_map==0)=nan;
    tt_count = log.perception__opponents.count;
    tt_losses = zeros(size(tt_count));
    
if(use_log2)
    tt_stamp2 = log_2.perception__opponents.stamp__tot - double(log.time_offset_nsec-log_2.time_offset_nsec)*1e-9;
    % relative
    tt_x_rel2 = log_2.perception__opponents.opponents__x_rel;
    tt_y_rel2 = log_2.perception__opponents.opponents__y_rel;
    tt_x_rel2(tt_x_rel2==0)=nan;
    tt_y_rel2(tt_y_rel2==0)=nan;
    tt_rho_dot2 = log_2.perception__opponents.opponents__rho_dot;
    tt_rho_dot2(tt_rho_dot2==0)=nan;
    tt_yaw_rel2 = log_2.perception__opponents.opponents__psi_rel;
    tt_yaw_rel2(tt_yaw_rel2==0)=nan;
    % map
    tt_x_map2 = log_2.perception__opponents.opponents__x_geom;
    tt_y_map2 = log_2.perception__opponents.opponents__y_geom;
    tt_x_map2(tt_x_map2==0)=nan;
    tt_y_map2(tt_y_map2==0)=nan;
    tt_vx2 = log_2.perception__opponents.opponents__vx;
    tt_vx2(tt_vx2==0)=nan;
    tt_ax2 = log_2.perception__opponents.opponents__ax;
    tt_ax2(tt_ax2==0)=nan;
    tt_yaw_map2 = log_2.perception__opponents.opponents__psi;
    tt_yaw_map2(tt_yaw_map2==0)=nan;
    tt_count2 = log_2.perception__opponents.count;
    tt_losses2 = zeros(size(tt_count2));
end

if(use_log3)
    tt_stamp3 = log_3.perception__opponents.stamp__tot - double(log.time_offset_nsec-log_3.time_offset_nsec)*1e-9; 
    % relative
    tt_x_rel3 = log_3.perception__opponents.opponents__x_rel;
    tt_y_rel3 = log_3.perception__opponents.opponents__y_rel;
    tt_x_rel3(tt_x_rel3==0)=nan;
    tt_y_rel3(tt_y_rel3==0)=nan;
    tt_rho_dot3 = log_3.perception__opponents.opponents__rho_dot;
    tt_rho_dot3(tt_rho_dot3==0)=nan;
    tt_yaw_rel3 = log_3.perception__opponents.opponents__psi_rel;
    tt_yaw_rel3(tt_yaw_rel3==0)=nan;
    % map
    tt_x_map3 = log_3.perception__opponents.opponents__x_geom;
    tt_y_map3 = log_3.perception__opponents.opponents__y_geom;
    tt_x_map3(tt_x_map3==0)=nan;
    tt_y_map3(tt_y_map3==0)=nan;
    tt_vx3 = log_3.perception__opponents.opponents__vx;
    tt_vx3(tt_vx3==0)=nan;
    tt_ax3 = log_3.perception__opponents.opponents__ax;
    tt_ax3(tt_ax3==0)=nan;
    tt_yaw_map3 = log_3.perception__opponents.opponents__psi;
    tt_yaw_map3(tt_yaw_map3==0)=nan;
    tt_count3 = log_3.perception__opponents.count;
    tt_losses3 = zeros(size(tt_count3));

end

% TARGET TRACKING REF
if(use_sim_ref)
    tt_count_ref = log.sim_out.count;
    tt_stamp_ref = log.sim_out.bag_stamp - double(log.time_offset_nsec-log.time_offset_nsec)*1e-9;
    % map
    tt_x_map_ref = log.sim_out.opponents__x_geom(:,1);
    tt_y_map_ref = log.sim_out.opponents__y_geom(:,1);
    tt_vx_ref = log.sim_out.opponents__vx(:,1);
    tt_ax_ref = log.sim_out.opponents__ax(:,1);
    tt_yaw_map_ref = log.sim_out.opponents__psi(:,1);
    % rel
    tt_x_rel_ref = log.sim_out.opponents__x_rel(:,1);
    tt_y_rel_ref = log.sim_out.opponents__y_rel(:,1);
    tt_rho_dot_ref = log.sim_out.opponents__rho_dot(:,1);
elseif(use_ref)
    tt_stamp_ref = (log_ref.timestamp - double(log.time_offset_nsec))*1e-9;
    % relative
    tt_x_rel_ref = log_ref.x_rel;
    tt_y_rel_ref = log_ref.y_rel;
    tt_rho_dot_ref = log_ref.rho_dot;
    % map
    tt_x_map_ref = log_ref.x_map;
    tt_y_map_ref = log_ref.y_map;
    tt_vx_ref = log_ref.speed;
    tt_yaw_map_ref = log_ref.yaw_map;
end


%% Plot opponent count


figure('name', 'Opp_count');
f=1;
axes(f) = nexttile([1,1]);
hold on;
plot(tt_stamp,tt_count,'Color',col.tt1,'DisplayName',name1);
max_opp = max(tt_count); 
if(use_log2)
    plot(tt_stamp2,tt_count2,'Color',col.tt2,'DisplayName',name2);
    max_opp = max([tt_count2; tt_count]);
end
if(use_log3)
    plot(tt_stamp3,tt_count3,'Color',col.tt3,'DisplayName',name3);
    max_opp = max([tt_count3; tt_count2; tt_count]);
end
if(use_sim_ref)
    plot(tt_stamp_ref,tt_count_ref,'Color',col.ref,'DisplayName','ref')
end

grid on;
title('opponent count [#]');
legend show



%% Plot State Variable MAP

figure('name', 'x_y_map');
tiledlayout(2,1);

% x
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_x_map(:,1:max_opp),'Color',col.tt1,'DisplayName',name1);
if(use_log2)
    plot(tt_stamp2,tt_x_map2(:,1:max_opp),'Color',col.tt2,'DisplayName',name2);
end
if(use_log3)
    plot(tt_stamp3,tt_x_map3(:,1:max_opp),'Color',col.tt3,'DisplayName',name3);
end
if(use_sim_ref || use_ref)
    plot(tt_stamp_ref,tt_x_map_ref,'Color',col.ref,'DisplayName','ref');
end
grid on;
title('x [m]');
legend show

% y
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_y_map(:,1:max_opp),'Color',col.tt1,'DisplayName',name1);
if(use_log2)
    plot(tt_stamp2,tt_y_map2(:,1:max_opp),'Color',col.tt2,'DisplayName',name2);
end
if(use_log3)
    plot(tt_stamp3,tt_y_map3(:,1:max_opp),'Color',col.tt3,'DisplayName',name3);
end
if(use_sim_ref || use_ref)
    plot(tt_stamp_ref,tt_y_map_ref,'Color',col.ref,'DisplayName','ref');
end
grid on;
title('y [m]');
legend show




%% Plot State Variable REL
figure('name', 'x_y_rel');
tiledlayout(2,1);

% x
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_x_rel(:,1:max_opp),'Color',col.tt1,'DisplayName',name1);
if(use_log2)
    plot(tt_stamp2,tt_x_rel2(:,1:max_opp),'Color',col.tt2,'DisplayName',name2);
end
if(use_log3)
    plot(tt_stamp3,tt_x_rel3(:,1:max_opp),'Color',col.tt3,'DisplayName',name3);
end
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref,tt_x_rel_ref,'Color',col.ref,'DisplayName','ref');
end
grid on;
title('x rel [m]');
legend show

% y
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_y_rel(:,1:max_opp),'Color',col.tt1,'DisplayName',name1);
if(use_log2)
    plot(tt_stamp2,tt_y_rel2(:,1:max_opp),'Color',col.tt2,'DisplayName',name2);
end
if(use_log3)
    plot(tt_stamp3,tt_y_rel3(:,1:max_opp),'Color',col.tt3,'DisplayName',name3);
end
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref,tt_y_rel_ref,'Color',col.ref,'DisplayName','ref');
end
grid on;
title('y rel [m]');
legend 


%vx
figure('name', 'speed_acc');
tiledlayout(2,1);

axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_vx(:,1:max_opp),'Color',col.tt1,'DisplayName',name1);
if(use_log2)
    plot(tt_stamp2,tt_vx2(:,1:max_opp),'Color',col.tt2,'DisplayName',name2);
end
if(use_log3)
    plot(tt_stamp3,tt_vx3(:,1:max_opp),'Color',col.tt3,'DisplayName',name3);
end
if(use_sim_ref || use_ref)
    plot(tt_stamp_ref,tt_vx_ref,'Color',col.ref,'DisplayName','ref');
end
grid on;
title('vx [m/s]');
legend show

% ax
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_ax(:,1:max_opp),'Color',col.tt1,'DisplayName',name1);
if(use_log2)
    plot(tt_stamp2,tt_ax2(:,1:max_opp),'Color',col.tt2,'DisplayName',name2);
end
if(use_log3)
    plot(tt_stamp3,tt_ax3(:,1:max_opp),'Color',col.tt3,'DisplayName',name3);
end
if(use_sim_ref)
    plot(tt_stamp_ref,tt_ax_ref,'Color',col.ref,'DisplayName','ref');
end
grid on;
title('ax [m/s^2]');
legend show



% heading
figure('name', 'Heading');
axes(f) = nexttile([1,1]);
f=f+1;

hold on;

tt_yaw_map = mod(tt_yaw_map,2*pi);
plot(tt_stamp,tt_yaw_map(:,1:max_opp),'Color',col.tt1,'DisplayName',name1);

if(use_log2)
    tt_yaw_map2 = mod(tt_yaw_map2,2*pi);
    plot(tt_stamp2,tt_yaw_map2(:,1:max_opp),'Color',col.tt2,'DisplayName',name2);
end

if(use_log3)
    tt_yaw_map3 = mod(tt_yaw_map3,2*pi);
    plot(tt_stamp3,tt_yaw_map3(:,1:max_opp),'Color',col.tt3,'DisplayName',name3);
end

if(use_sim_ref || use_ref)
    tt_yaw_map_ref = mod(tt_yaw_map_ref,2*pi);
    plot(tt_stamp_ref,tt_yaw_map_ref,'Color',col.ref,'DisplayName','ref');
    xlim(axes, [0 max(tt_stamp_ref)]);
end
grid on;
title('h [deg]');
legend show
linkaxes(axes,'x');



%% Interpolation
% interpolate on the main tt system

if(compute_err_std && (use_ref || use_sim_ref))
    if(use_ref || use_sim_ref)
        for i = 1 : length(tt_stamp_ref)
             tt_x_map_ref_inter = interp1(tt_stamp_ref,tt_x_map_ref,tt_stamp); 
             tt_y_map_ref_inter = interp1(tt_stamp_ref,tt_y_map_ref,tt_stamp);
             tt_vx_ref_inter = interp1(tt_stamp_ref,tt_vx_ref,tt_stamp);
             tt_yaw_map_ref_inter = interp1(tt_stamp_ref,tt_yaw_map_ref,tt_stamp);
             if(use_sim_ref)
                 tt_ax_ref_inter = interp1(tt_stamp_ref,tt_ax_ref,tt_stamp);
             end
        end
    end
    
    if(use_log2)
        for i = 1 : length(tt_stamp2)
             tt_x_map_ref2_inter = interp1(tt_stamp_ref,tt_x_map_ref,tt_stamp2); 
             tt_y_map_ref2_inter = interp1(tt_stamp_ref,tt_y_map_ref,tt_stamp2);
             tt_vx_ref2_inter = interp1(tt_stamp_ref,tt_vx_ref,tt_stamp2);
             tt_ax_ref2_inter = interp1(tt_stamp_ref,tt_ax_ref,tt_stamp2);
             tt_yaw_map_ref2_inter = interp1(tt_stamp_ref,tt_yaw_map_ref,tt_stamp2);
        end
    end
    
    if(use_log3)
        for i = 1 : length(tt_stamp3)
             tt_x_map_ref3_inter = interp1(tt_stamp_ref,tt_x_map_ref,tt_stamp3); 
             tt_y_map_ref3_inter = interp1(tt_stamp_ref,tt_y_map_ref,tt_stamp3);
             tt_vx_ref3_inter = interp1(tt_stamp_ref,tt_vx_ref,tt_stamp3);
             tt_ax_ref3_inter = interp1(tt_stamp_ref,tt_ax_ref,tt_stamp3);
             tt_yaw_map_ref3_inter = interp1(tt_stamp_ref,tt_yaw_map_ref,tt_stamp3);
        end
    end
end


%% Error Analisys

if(compute_err_std && use_ref)
    tt_x_map_error = tt_x_map - tt_x_map_ref_inter;
    tt_y_map_error = tt_y_map - tt_y_map_ref_inter;
    tt_vx_error = tt_vx - tt_vx_ref_inter;
    tt_ax_error = tt_ax - tt_ax_ref_inter;
    tt_yaw_error = tt_yaw_map - tt_yaw_map_ref_inter;
    
    tt_x_map_error = tt_x_map_error(~isnan(tt_x_map_error));
    tt_y_map_error = tt_y_map_error(~isnan(tt_y_map_error));
    tt_vx_error = tt_vx_error(~isnan(tt_vx_error));
    tt_ax_error = tt_ax_error(~isnan(tt_ax_error));
    tt_yaw_error = tt_yaw_error(~isnan(tt_yaw_error));
    
    tt_error_std = [std(tt_x_map_error); std(tt_x_map_error); std(tt_vx_error); std(tt_yaw_error)];
    
    if (use_log2)
        tt_x_map2_error = tt_x_map2 - tt_x_map_ref2_inter;
        tt_y_map2_error = tt_y_map2 - tt_y_map_ref2_inter;
        tt_vx2_error = tt_vx2 - tt_vx_ref2_inter;
        tt_ax2_error = tt_ax2 - tt_ax_ref2_inter;
        tt_yaw2_error = tt_yaw_map2 - tt_yaw_map_ref2_inter;
        
        tt_x_map2_error = tt_x_map2_error(~isnan(tt_x_map2_error));
        tt_y_map2_error = tt_y_map2_error(~isnan(tt_y_map2_error));
        tt_vx2_error = tt_vx2_error(~isnan(tt_vx2_error));
        tt_ax2_error = tt_ax2_error(~isnan(tt_ax2_error));
        tt_yaw2_error = tt_yaw2_error(~isnan(tt_yaw2_error));

        tt_error_std2 = [std(tt_x_map2_error); std(tt_x_map2_error); std(tt_vx2_error); std(tt_yaw2_error)];
        tt_error_std = [tt_error_std tt_error_std2];
    end
    if(use_log3)
        tt_x_map3_error = tt_x_map3 - tt_x_map_ref3_inter;
        tt_y_map3_error = tt_y_map3 - tt_y_map_ref3_inter;
        tt_vx3_error = tt_vx3 - tt_vx_ref3_inter;
        tt_ax3_error = tt_ax3 - tt_ax_ref3_inter;
        tt_yaw3_error = tt_yaw_map3 - tt_yaw_map_ref3_inter;
        
        tt_x_map3_error = tt_x_map3_error(~isnan(tt_x_map3_error));
        tt_y_map3_error = tt_y_map3_error(~isnan(tt_y_map3_error));
        tt_vx3_error = tt_vx3_error(~isnan(tt_vx3_error));
        tt_ax3_error = tt_ax3_error(~isnan(tt_ax3_error));
        tt_yaw3_error = tt_yaw3_error(~isnan(tt_yaw3_error));

        tt_error_std3 = [std(tt_x_map3_error); std(tt_x_map3_error); std(tt_vx3_error); std(tt_yaw3_error)];
        tt_error_std = [tt_error_std tt_error_std2 tt_error_std3];
    end
end