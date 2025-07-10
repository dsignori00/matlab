function new_line = LineSmoothingEdgeCost(line, dn_max, der_cost, edge_cost,max_iter, opt_tol, func_tol)

    line_closed = CloseLine(line);

    x        = line_closed.x(1:end-1);
    y        = line_closed.y(1:end-1);
    dx_temp  = -diff(line_closed.y);
    dy_temp  = diff(line_closed.x);
    dx       = dx_temp ./ sqrt(dx_temp.^2+dy_temp.^2);
    dy       = dy_temp ./ sqrt(dx_temp.^2+dy_temp.^2);

    options                         = optimoptions('lsqnonlin');
    options.Display                 = 'iter';
    options.MaxIterations           = max_iter;
    options.OptimalityTolerance     = opt_tol;
    options.FunctionTolerance       = func_tol;
    options.MaxFunctionEvaluations = length(line_closed.x) * max_iter;

    x0    = zeros(size(x));
    lb    = -dn_max * ones(size(x));
    ub    = dn_max * ones(size(x));

    if max_iter > 0
        alpha_opt = lsqnonlin(@(alpha)[calcCurvature(x+alpha.*dx,y+alpha.*dy,1); ...
                                       der_cost*diff(calcCurvature(x+alpha.*dx,y+alpha.*dy,1)); ...
                                       edge_cost*(alpha(1)-alpha(end))],x0,lb,ub,options);
    else
        alpha_opt = x0;
    end

    x_smooth          = x + alpha_opt.*dx;
    x_smooth(end+1)   = x_smooth(1);
    y_smooth          = y + alpha_opt.*dy;
    y_smooth(end+1)   = y_smooth(1);

    new_line.x = x_smooth;
    new_line.y = y_smooth;

    if isfield(line, 'geo_base')
        new_line.geo_base = line.geo_base;
        new_line = complete_line_fields(new_line);
    end

    if ~line.closed
        new_line = OpenLine(new_line);
    end

    function rho = calcCurvature(x,y,downsampling)

        if size(x) ~= size(y)
            error('Inputs dimensions must agree.')
        end

        rho = zeros(size(x));

        if x(1) == x(end) && y(1) == y(end)  % first and last point are the same
            path_length = length(x)-1;       % actual path is one sample smaller
        else                                 % first and last point are different
            path_length = length(x);
        end

        for i = 1:length(x)

            % Compute circular indexes
            h = i-downsampling;
            if h < 1
                h = path_length+h;
            end
            k = i+downsampling;
            if k > path_length
                k = k-path_length;
            end

            % Curvature computation using the three points at index h,i,k
            a = sqrt((x(k) - x(i))^ 2 + (y(k) - y(i))^ 2);                               % triangle first side
            b = sqrt((x(i) - x(h))^ 2 + (y(i) - y(h))^ 2);                               % triangle second side
            c = sqrt((x(k) - x(h))^2 + (y(k) - y(h))^ 2);                                % triangle third side
            A = ((x(i) - x(h)) * (y(k) - y(h)) - (y(i) - y(h)) * (x(k) - x(h))) / 2.0;   % triangle signed area depending on the orientation of the three points (clockwise or anti-clockwise)
            rho(i) = 4.0 * A / (a * b * c);                                              % curvature of the circle circumscribing the triangle

        end

    end

end
