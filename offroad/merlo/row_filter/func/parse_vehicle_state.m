function out = parse_vehicle_state(log)
    out = struct();
    out.stamp = log.localization__vehicle_state.stamp;
    out.x = log.localization__vehicle_state.x;
    out.y = log.localization__vehicle_state.y;
    out.z = log.localization__vehicle_state.z;
    out.heading = log.localization__vehicle_state.heading;
    out.pitch = log.localization__vehicle_state.pitch;
    out.roll = log.localization__vehicle_state.roll;
    out.vx = log.localization__vehicle_state.vx;
    out.ax = log.localization__vehicle_state.ax;
    out.ay = log.localization__vehicle_state.ay;
    out.yaw_rate = log.localization__vehicle_state.yaw_rate;
end