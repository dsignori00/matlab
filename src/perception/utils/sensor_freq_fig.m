%% AVERAGE SENSOR FREQUENCY - DROP OUT PROB

if(drop_out_analyses)
    t_start   = 550;
    t_stop    = 640;
    nominal_f = 20;
    
    val_lid_clust = sqrt(lid_clust.x_map_err.^2+lid_clust.y_map_err.^2)<15 & lid_clust.sens_stamp>t_start & lid_clust.sens_stamp<t_stop;
    lid_clust.count = sum(val_lid_clust);
    lid_clust.avg_freq = lid_clust.count/(t_stop-t_start);
    drop_out.lid_clust = lid_clust.count/(nominal_f*(t_stop-t_start));
    
    val_rad_clust = sqrt(rad_clust.x_map_err.^2+rad_clust.y_map_err.^2)<15 & rad_clust.sens_stamp>t_start & rad_clust.sens_stamp<t_stop;
    rad_clust.count = sum(val_rad_clust);
    rad_clust.avg_freq = rad_clust.count/(t_stop-t_start);
    drop_out.rad_clust = rad_clust.count/(nominal_f*(t_stop-t_start));
    
    val_lid_pp = sqrt(lid_pp.x_map_err.^2+lid_pp.y_map_err.^2)<15 & lid_pp.sens_stamp>t_start & lid_pp.sens_stamp<t_stop;
    lid_pp.count = sum(val_lid_pp);
    lid_pp.avg_freq = lid_pp.count/(t_stop-t_start);
    drop_out.lid_pp = lid_pp.count/(nominal_f*(t_stop-t_start));
    
    val_cam_yolo = sqrt(cam_yolo.x_map_err.^2+cam_yolo.y_map_err.^2)<15 & cam_yolo.sens_stamp>t_start & cam_yolo.sens_stamp<t_stop;
    cam_yolo.count = sum(val_cam_yolo);
    cam_yolo.avg_freq = cam_yolo.count/(t_stop-t_start);
    drop_out.cam_yolo = cam_yolo.count/(nominal_f*(t_stop-t_start));
end
