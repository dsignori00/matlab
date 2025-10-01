function [x,y,psi]=Darboux2Cart_2D(ref_line,s,n,csi) 
    % Get ref_line size
    track_size = length(ref_line.X);
    track_length = ref_line.Sref(end) + sqrt( (ref_line.X(1) - ref_line.X(end))^2 + (ref_line.Y(1) - ref_line.Y(end))^2 );

    % Normalize s
    s = mod(s, track_length);
    
    % Find closest point on ref_line
    [dist_min, idx_min] = min(abs(ref_line.Sref - s));
    
    % Find closest point between the two adjacent points
    idx_prev=idx_min-1;
    idx_next=idx_min+1;
    
    if idx_min==1
        idx_prev=track_size;
    elseif idx_min==track_size
        idx_next=1;
    end
        
    dist_next = abs(s - ref_line.Sref(idx_next));
    dist_prev = abs(s - ref_line.Sref(idx_prev));
    
    if dist_next < dist_prev
        idx_t1 = idx_min;
        idx_t2 = idx_next;
        dist_t1 = dist_min;
    else
        idx_t1 = idx_prev;
        idx_t2 = idx_min;
        dist_t1 = dist_prev;
    end    
    
    % Get coordinates of the two closest points
    t1.x = ref_line.X(idx_t1);
    t1.y = ref_line.Y(idx_t1);
    t2.x = ref_line.X(idx_t2);
    t2.y = ref_line.Y(idx_t2);

    % Compute actual closest point on the line passing through t1 and t2
    a_temp = t2.x-t1.x;
    b_temp = t2.y-t1.y;
    lambda = dist_t1 / sqrt(a_temp^2 + b_temp^2);
    n2.x = t1.x + a_temp * lambda;
    n2.y = t1.y + b_temp * lambda;
    
    % Compute Darboux frame
    a_dpl = ref_line.dx(idx_t1);
    b_dpl = ref_line.dy(idx_t1);
    
    % Convert
    x = n2.x - b_dpl * n;
    y = n2.y + a_dpl * n;
    
    psi = atan2(b_dpl,a_dpl) + csi;
end