function s = compute_curv_abscissa(points)

    N_points = size(points, 1);

    s = nan(N_points, 1);
    s(1) = 0;

    for i=1:(N_points-1)
        s(i+1) = s(i) + sqrt((points(i+1, 1)-points(i, 1)).^2 + (points(i+1, 2)-points(i, 2)).^2);
    end

end

