function closestIdx = ComputeClosestIdx(x, y, traj_struct)
% Returns the index of the closest point on the trajectory to (x, y)

% Extract trajectory points
trajX = traj_struct.X(:);
trajY = traj_struct.Y(:);

% Compute squared distances all at once (no repmat)
dx = trajX - x;
dy = trajY - y;
distsq = dx.^2 + dy.^2;

% Find index of minimum distance
[~, closestIdx] = min(distsq);
end


