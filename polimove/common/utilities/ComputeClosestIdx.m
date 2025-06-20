function [closestIdx] = compute_closestIdx(x, y, traj_struct)
% compute_closestIdx: given the (x,y) position of a vehicle inside the track
% and a trajecotry computes the closest point of the trajectory to the
% vehicle
%% compute_closestIdx:

dims = size(traj_struct.X);

% if column
if dims(1)>dims(2)
    % conversion of the trajectory from the struct form to a vector form
    traj = [traj_struct.X'; traj_struct.Y'];
else
    % conversion of the trajectory from the struct form to a vector form
    traj = [traj_struct.X; traj_struct.Y];
end

traj_length = max(dims);
% computation of closest idx
[dist,closestIdx] = min(sum((traj-repmat([x;y],1,traj_length)).^2));
end

