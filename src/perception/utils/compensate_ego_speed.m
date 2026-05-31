function opp_vx = compensate_ego_speed(pos_ego, v_ego, ego_yaw, opp_yaw, range_rate, x_map, y_map)
% COMPENSATE_EGO_SPEED - Computes opponent longitudinal velocity in its COG frame
% for one opponent over multiple time steps.
%
% INPUTS (all Nx1 or Nx2):
%   pos_ego  : Nx2 ego positions [x, y]
%   v_ego    : Nx2 ego velocities [vx, vy] in body frame
%   ego_yaw  : Nx1 ego heading in map frame [rad]
%   opp_yaw  : Nx1 opponent heading in map frame [rad]
%   range_rate : Nx1 radar LOS velocities
%   x_map, y_map : Nx1 opponent positions over time
%
% OUTPUT:
%   opp_vx : Nx1 opponent longitudinal velocity along its COG x-axis

    % --- radar LOS vectors ---
    dx = x_map - pos_ego(:,1);
    dy = y_map - pos_ego(:,2);
    bearing = atan2(dy, dx);
    azimuth = atan2(sin(bearing - ego_yaw), cos(bearing - ego_yaw));

    % --- radar LOS unit vectors in ego body frame ---
    r_hat_body_x = cos(azimuth);
    r_hat_body_y = sin(azimuth);

    % --- project ego velocity along radar LOS ---
    v_ego_along_radar = v_ego(:,1) .* r_hat_body_x + v_ego(:,2) .* r_hat_body_y;

    % --- target velocity along radar LOS ---
    v_target_along_radar = v_ego_along_radar + range_rate;

    % --- radar LOS unit vectors in map frame ---
    r_hat_map_x = cos(ego_yaw + azimuth);
    r_hat_map_y = sin(ego_yaw + azimuth);

    % --- target velocity vector in map frame ---
    v_target_map_x = v_target_along_radar .* r_hat_map_x;
    v_target_map_y = v_target_along_radar .* r_hat_map_y;

    % --- rotate velocity into opponent COG frame ---
    cos_opp = cos(opp_yaw);
    sin_opp = sin(opp_yaw);
    opp_vx = cos_opp .* v_target_map_x + sin_opp .* v_target_map_y;  % longitudinal

end
