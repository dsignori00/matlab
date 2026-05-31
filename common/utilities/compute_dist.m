function [dist,closestIdx] = compute_dist(x, y, x_traj,y_traj)
% compute_closestIdx: given the (x,y) position of a vehicle inside the track
% and a trajecotry computes the closest point of the trajectory to the
% vehicle
%% compute_closestIdx:

dims = size(x_traj);

% if column
if dims(1)>dims(2)
    traj = [x_traj'; y_traj'];
else
    traj = [x_traj; y_traj];
end

traj_length = max(dims);
[dist,closestIdx] = min(sum((traj-repmat([x;y],1,traj_length)).^2));
end