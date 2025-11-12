function [v2v,ego] = get_data(log, log_ego, ego_vs_ego)

    MPS2KPH = 3.6;
    % V2V DETECTIONS
    if(~ego_vs_ego)
        v2v.sens_stamp = log.perception__v2v__detections.sensor_stamp__tot;
        % map
        v2v.x = log.perception__v2v__detections.detections__x_map;
        v2v.y = log.perception__v2v__detections.detections__y_map;
        v2v.vx = log.perception__v2v__detections.detections__vx*MPS2KPH;
        v2v.yaw = log.perception__v2v__detections.detections__yaw_map;
        v2v.x(v2v.x==0)=nan;
        v2v.y(v2v.y==0)=nan;
        v2v.vx(v2v.vx==0)=nan;
        v2v.yaw(v2v.yaw==0)=nan;
        v2v.yaw = unwrap(v2v.yaw);
        v2v.count = log.perception__v2v__detections.count;
        v2v.max_opp = max(v2v.count);
        v2v = valid_opponents(v2v);
    else
        v2v.sens_stamp = log.estimation.stamp__tot;
        v2v.x = log.estimation.x_cog;
        v2v.y = log.estimation.y_cog;
        v2v.vx = log.estimation.vx*MPS2KPH; 
        v2v.yaw = log.estimation.heading; 
        v2v.ax = log.estimation.ax;
        v2v.ay = log.estimation.ay;
        v2v.ax(v2v.ax==0)=nan;
        v2v.ay(v2v.ay==0)=nan;
        v2v.x(v2v.x==0)=nan;
        v2v.y(v2v.y==0)=nan;
        v2v.vx(v2v.vx==0)=nan;
        v2v.yaw(v2v.yaw==0)=nan;
        v2v.yaw = unwrap(v2v.yaw);
        v2v.count = 1;
        v2v.max_opp = 1; 
    end

    % ESTIMATION
    ego.stamp = log_ego.estimation.stamp__tot;
    ego.x = log_ego.estimation.x_cog;
    ego.y = log_ego.estimation.y_cog;
    ego.vx = log_ego.estimation.vx*MPS2KPH; 
    ego.yaw = log_ego.estimation.heading;
    ego.ax = log_ego.estimation.ax;
    ego.ay = log_ego.estimation.ay;
    ego.x(ego.x==0)=nan;
    ego.y(ego.y==0)=nan;
    ego.vx(ego.vx==0)=nan;
    ego.yaw(ego.yaw==0)=nan;
    ego.yaw = unwrap(ego.yaw);
    ego.ax(ego.ax==0)=nan;
    ego.ay(ego.ay==0)=nan;

end