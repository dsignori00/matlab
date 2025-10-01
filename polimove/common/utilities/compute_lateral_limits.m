function [nl, nr] = compute_lateral_limits(center_line, d_knot_vec, left_border, right_border)

    N_points_c = size(center_line, 1);

    center_line_knot_points = compute_knot_points(center_line, d_knot_vec);
    center_line_normals = compute_normals(center_line, d_knot_vec);

    s_centerline = [0; cumsum(d_knot_vec(:))];
    s_left = compute_arc_length(left_border);
    s_right = compute_arc_length(right_border);

    left_border_padded = [left_border; left_border(1, :)];
    right_border_padded = [right_border; right_border(1, :)];

    nl = nan(N_points_c, 1);
    nr = nan(N_points_c, 1);

    segment_length = 10.0;  
    s_window = 1000.0;  

    for i = 1:N_points_c
        curr_point = center_line_knot_points(i, :);
        curr_normal = center_line_normals(i, :);
        s_curr = s_centerline(i);

            
        % Normal segment
        p1 = curr_point - segment_length * curr_normal;
        p2 = curr_point + segment_length * curr_normal;

        % --- LEFT INTERSECTION ---
        [x_l, y_l, i_l] = polyxpoly(left_border_padded(:, 1), left_border_padded(:, 2), ...
                                    [p1(1), p2(1)], [p1(2), p2(2)]);

        best_dl = [];
        min_dist_l = inf;

        for j = 1:length(x_l)
            idx = i_l(j);
            % Interpolate s on border
            p0 = left_border_padded(idx, :);
            p1b = left_border_padded(idx + 1, :);
            ds = norm(p1b - p0);
            if ds == 0, continue; end

            if idx == size(left_border, 1)
                s0 = s_left(end);
                s1 = s_left(1) + s_left(end);  
            else
                s0 = s_left(idx);
                s1 = s_left(idx + 1);
            end

            alpha = norm([x_l(j), y_l(j)] - p0) / ds;
            s_int = (1 - alpha) * s0 + alpha * s1;

            % Filter by s-window
            circ_dist = min(abs(s_int - s_curr), s_left(end) - abs(s_int - s_curr));
            if circ_dist>= s_window
                sprintf("WARNING: i = %d | Circular distance %f exceeds window %f\n", i, circ_dist, s_window);
            end
            if circ_dist <= s_window
                dl = [x_l(j), y_l(j)] - curr_point;
                dist = norm(dl);
                if dist < min_dist_l
                    min_dist_l = dist;
                    best_dl = dl;
                end
            end
        end

        if ~isempty(best_dl)
            nl(i) = dot(best_dl, curr_normal);
        end

        % --- RIGHT INTERSECTION ---
        [x_r, y_r, i_r] = polyxpoly(right_border_padded(:, 1), right_border_padded(:, 2), ...
                                    [p1(1), p2(1)], [p1(2), p2(2)]);

        best_dr = [];
        min_dist_r = inf;

        for j = 1:length(x_r)
            idx = i_r(j);

            % Interpolate s on border
            p0 = right_border_padded(idx, :);
            p1b = right_border_padded(idx + 1, :);
            ds = norm(p1b - p0);
            if ds == 0
                fprintf("WARNING: i = %d | Zero-length segment at idx = %d\n", i, idx);
            end
            if ds == 0, continue; end

            if idx == size(right_border, 1)
                s0 = s_right(end);
                s1 = s_right(1) + s_right(end);
            else
                s0 = s_right(idx);
                s1 = s_right(idx + 1);
            end

            alpha = norm([x_r(j), y_r(j)] - p0) / ds;
            s_int = (1 - alpha) * s0 + alpha * s1;

            % Filter by s-window
            circ_dist = min(abs(s_int - s_curr), s_right(end) - abs(s_int - s_curr));
            if circ_dist <= s_window
                dr = [x_r(j), y_r(j)] - curr_point;
                dist = norm(dr);
                if dist < min_dist_r
                    min_dist_r = dist;
                    best_dr = dr;
                end
            end
        end

        if ~isempty(best_dr)
            nr(i) = dot(best_dr, curr_normal);
        end

        sprintf("i = %d | Left limit: %f | Right limit: %f\n", i, nl(i), nr(i));

    end
end

% Helper to compute arc-length vector
function s = compute_arc_length(points)
    diffs = diff(points);
    ds = sqrt(sum(diffs.^2, 2));
    s = [0; cumsum(ds)];
end
