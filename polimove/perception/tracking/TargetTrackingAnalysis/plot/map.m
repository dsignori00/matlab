%% MAP
fig = figure('name','MAP');

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @refreshTimeButtonPushed;

%#ok<*UNRCH>
%#ok<*INUSD>

function refreshTimeButtonPushed(src,event)
    axes = evalin('base', 'axes');
    traj_db = evalin('base', 'trajDatabase');
    use_ref = evalin('base', 'use_ref');
    compare = evalin('base', 'compare');
    use_sim_ref = evalin('base', 'use_sim_ref');
    col = evalin('base', 'col');
    lid_clust = evalin('base', 'lid_clust');
    rad_clust = evalin('base', 'rad_clust');
    cam_yolo = evalin('base', 'cam_yolo');
    lid_pp = evalin('base', 'lid_pp');
    tt = evalin('base','tt');
    if(compare); tt2 = evalin('base','tt2'); end
    if(compare); name2 = evalin('base','name2'); end
    if(use_ref || use_sim_ref); gt =evalin('base','gt'); end

    t_lim=xlim(axes(1));
    t1_lid_clust = find(lid_clust.sens_stamp>t_lim(1),1);
    tend_lid_clust = find(lid_clust.sens_stamp<t_lim(2),1,'last');
    t1_rad_clust = find(rad_clust.sens_stamp>t_lim(1),1);
    tend_rad_clust = find(rad_clust.sens_stamp<t_lim(2),1,'last');
    t1_cam_yolo = find(cam_yolo.sens_stamp>t_lim(1),1);
    tend_cam_yolo = find(cam_yolo.sens_stamp<t_lim(2),1,'last');
    t1_lid_pp = find(lid_pp.sens_stamp>t_lim(1),1);
    tend_lid_pp = find(lid_pp.sens_stamp<t_lim(2),1,'last');
    t1_tt = find(tt.stamp>t_lim(1),1);
    tend_tt = find(tt.stamp<t_lim(2),1,'last');
    if(compare)
        t1_tt2 = find(tt2.stamp>t_lim(1),1);
        tend_tt2 = find(tt2.stamp<t_lim(2),1,'last');
    end
    if(use_ref || use_sim_ref)
        t1_tt_ref = find(gt.stamp>t_lim(1),1);
        tend_tt_ref = find(gt.stamp<t_lim(2),1,'last');
    end

    subplot(1,1,1)
    cla reset 
    ylabel('map')
    hold on
    grid on
    xlabel('x[m]')
    ylabel('y[m]')
    axis 'equal'

    % plot track lines
    id_left = length(traj_db) - 2;
    id_right = length(traj_db) - 1;
    plot(traj_db(id_left).X, traj_db(id_left).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(traj_db(id_right).X, traj_db(id_right).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');


    plot(lid_clust.x_map(t1_lid_clust:tend_lid_clust), lid_clust.y_map(t1_lid_clust:tend_lid_clust),'.','markersize',20,'Color',col.lidar,'displayname','Lid Clust');
    plot(rad_clust.x_map(t1_rad_clust:tend_rad_clust), rad_clust.y_map(t1_rad_clust:tend_rad_clust),'.','markersize',20,'Color',col.radar,'displayname','Rad Clust');
    plot(cam_yolo.x_map(t1_cam_yolo:tend_cam_yolo), cam_yolo.y_map(t1_cam_yolo:tend_cam_yolo),'.','markersize',20,'Color',col.camera,'displayname','Camera');
    plot(lid_pp.x_map(t1_lid_pp:tend_lid_pp), lid_pp.y_map(t1_lid_pp:tend_lid_pp),'.','markersize',20,'Color',col.pointpillars,'displayname','Lid PP');
    plot(tt.x_map(t1_tt:tend_tt,1:tt.max_opp),tt.y_map(t1_tt:tend_tt,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
    if(compare); plot(tt2.x_map(t1_tt2:tend_tt2,1:tt2.max_opp),tt2.y_map(t1_tt2:tend_tt2,1:tt2.max_opp),'Color',col.tt2,'DisplayName',name2); end
    if(use_ref || use_sim_ref)
        plot(gt.x_map(t1_tt_ref:tend_tt_ref),gt.y_map(t1_tt_ref:tend_tt_ref),'Color',col.ref,'DisplayName','Grond Truth');
    end
    legend show
end