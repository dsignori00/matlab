function [heading, idxs] = get_heading (pos, trajDatabase)
    % given the position in map frame returns the traj database heading
    out = NaN(length(pos(:,1)),1);
    for j=1:length(pos(:,1))
        x = pos(j,1);
        y = pos(j,2);
        if(isnan(x) || isnan(y))
            continue;
        end
        min_dist = inf;
        traj = 0;
        for i=1:length(trajDatabase)
            [dist, idx] = compute_dist(x,y,trajDatabase(i).X,trajDatabase(i).Y);
            if(dist<min_dist)
                min_dist = dist;
                clos_idx = idx;
                traj = i;
            end
        end
        out(j,1) = trajDatabase(traj).Heading(clos_idx);
        out(j,2) = clos_idx;
    end
    heading = out(:,1);
    idxs = out(:,2);
end