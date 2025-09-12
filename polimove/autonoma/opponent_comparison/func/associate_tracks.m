function v2v = associate_tracks(v2v)
    fields = {'s','x','y','vx','yaw','index'};
    [N, nCol] = size(v2v.s);

    for i = 2:N
        prevRow = v2v.s(i-1,:);
        currRow = v2v.s(i,:);

        % Build full cost matrix (nCol × nCol)
        cost = nan(nCol);
        for a = 1:nCol
            for b = 1:nCol
                if isnan(prevRow(a)) && isnan(currRow(b))
                    cost(a,b) = 0;              % NaN ↔ NaN = perfect match
                elseif isnan(prevRow(a)) || isnan(currRow(b))
                    cost(a,b) = 1e6;            % NaN ↔ valid = huge penalty
                else
                    cost(a,b) = abs(prevRow(a) - currRow(b)); % normal distance
                end
            end
        end

        % Find optimal assignment
        pairs = matchpairs(cost, 1e6);

        % Reset permutation to identity
        perm = 1:nCol;

        % Update mapping from pairs
        for p = 1:size(pairs,1)
            prevIdx = pairs(p,1);
            currIdx = pairs(p,2);
            perm(currIdx) = prevIdx;
        end

        % Apply permutation row-wise
        for f = fields
            tmp = v2v.(f{1})(i,:);
            v2v.(f{1})(i,:) = tmp(perm);
        end
    end
end

