function rho = calc_curvature(x,y,downsampling,closed_path)

if size(x) ~= size(y)
    error('Inputs dimensions must agree.')
end

rho = zeros(size(x));

if closed_path % closed path
    
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
    
else % open path
    
    for i = 2:length(x)-1
        
        % Compute three successive indexes
        h = max(i - downsampling,1);
        k = min(i + downsampling,length(x));
        
        % Curvature computation using the three points at index h,i,k
        a = sqrt((x(k) - x(i))^ 2 + (y(k) - y(i))^ 2);
        b = sqrt((x(i) - x(h))^ 2 + (y(i) - y(h))^ 2);
        c = sqrt((x(k) - x(h))^2 + (y(k) - y(h))^ 2);
        A = ((x(i) - x(h)) * (y(k) - y(h)) - (y(i) - y(h)) * (x(k) - x(h))) / 2.0;
        rho(i) = 4.0 * A / (a * b * c);

    end
    rho(1)   = rho(2);
    rho(end) = rho(end-1);
    
end

end