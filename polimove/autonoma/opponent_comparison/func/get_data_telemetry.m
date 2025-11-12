function [v2v,ego] = get_data_telemetry(log, log_ego, ego_vs_ego)

    MPS2KPH = 3.6;
    % V2V DETECTIONS
    if(~ego_vs_ego)
        v2v.sens_stamp = log.telemetry__high.stamp__tot;
        % map
        v2v.x = log.telemetry__high.x_geom;
        v2v.y = log.telemetry__high.y_geom;
        v2v.yaw = log.telemetry__high.heading;
        v2v.x(v2v.x==0)=nan;
        v2v.y(v2v.y==0)=nan;
        v2v.yaw(v2v.yaw==0)=nan;
        v2v.yaw = unwrap(v2v.yaw);
        v2v.count = log.telemetry__high.count;
        v2v.max_opp = max(v2v.count);
        v2v.x(:,v2v.max_opp+1:end)=[];
        v2v.y(:,v2v.max_opp+1:end)=[];
        v2v.yaw(:,v2v.max_opp+1:end)=[];
    else
        v2v.sens_stamp = log.telemetry__high.stamp__tot;
        v2v.x = log.telemetry__high.x_cog;
        v2v.y = log.telemetry__high.y_cog;
        v2v.vx = log.telemetry__high.vx*MPS2KPH; 
        v2v.yaw = log.telemetry__high.heading; 
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

    % telemetry__high
    ego.stamp = log_ego.telemetry__high.stamp__tot;
    ego.x = log_ego.telemetry__high.x_cog;
    ego.y = log_ego.telemetry__high.y_cog;
    ego.vx = log_ego.telemetry__high.vx*MPS2KPH; 
    ego.yaw = log_ego.telemetry__high.heading;
    ego.x(ego.x==0)=nan;
    ego.y(ego.y==0)=nan;
    ego.vx(ego.vx==0)=nan;
    ego.yaw(ego.yaw==0)=nan;
    ego.yaw = unwrap(ego.yaw);
end