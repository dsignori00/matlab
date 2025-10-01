function [s,n,csi]=Cart2Darboux_2D(ref_line,gps_x,gps_y,gps_psi,idx_min) 
    % Get ref_line size
    track_size = length(ref_line.X);

    % Set point n1 equal to gps reading
    n1.x = gps_x;
    n1.y = gps_y;

    % Find closest point to n1
    if nargin < 5
      [~, idx_min] = min(sqrt((n1.x-ref_line.X).^2+(n1.y-ref_line.Y).^2));
    end
    
    idx_prev=idx_min-1;
    idx_next=idx_min+1;
    
    if idx_min==1
        idx_prev=track_size;
    elseif idx_min==track_size
        idx_next=1;
    end
        
    dist_next = sqrt((n1.x-ref_line.X(idx_next)).^2+(n1.y-ref_line.Y(idx_next)).^2);
    dist_prev = sqrt((n1.x-ref_line.X(idx_prev)).^2+(n1.y-ref_line.Y(idx_prev)).^2);

    % Find closest point between the two adjacent points
    if dist_next < dist_prev
        idx_t1 = idx_min;
        idx_t2 = idx_next;
    else
        idx_t1 = idx_prev;
        idx_t2 = idx_min;
    end

    % Get coordinates of the two closest points
    t1.x = ref_line.X(idx_t1);
    t1.y = ref_line.Y(idx_t1);
    t2.x = ref_line.X(idx_t2);
    t2.y = ref_line.Y(idx_t2);

    % Compute actual closest point on the line passing through t1 and t2
    a_temp = t2.x-t1.x;
    b_temp = t2.y-t1.y;
    lambda = (a_temp*(n1.x-t1.x)+b_temp*(n1.y-t1.y)) / (a_temp^2+b_temp^2);
    n2.x = t1.x + a_temp * lambda;
    n2.y = t1.y + b_temp * lambda;
    
    % Compute Darboux frame
    a_dpl = ref_line.dx(idx_t1);
    b_dpl = ref_line.dy(idx_t1);
    d_dpl = -(a_dpl * n2.x + b_dpl * n2.y);
        
    % Get Darboux frame from reference line 
    % Alternatively, we could use [vt,vn,vm,R] = getDarbouxFrame(t1,t2,n1_proj,n2);
    vt.x = ref_line.dx(idx_t1);
    vt.y = ref_line.dy(idx_t1);
    vt.z = 0.0;
    vn.x = -ref_line.dy(idx_t1);
    vn.y = ref_line.dx(idx_t1);
    vn.z = 0.0;
    vm.x = 0.0;
    vm.y = 0.0;
    vm.z = 1.0;
    R = [vt.x, vn.x, vm.x; 
         vt.y, vn.y, vm.y; 
         vt.z, vn.z, vm.z];

    % Compute curvilinear abscissa
    if (lambda < 0)
        s = ref_line.S(idx_t1);
    elseif (lambda > 1)
        s = ref_line.S(idx_t2);
    else
        s = ref_line.S(idx_t1) + sqrt((t1.x-n2.x)^2+(t1.y-n2.y)^2);
    end
    
    % Compute lateral distance
    n = (n1.x-n2.x)*vn.x+(n1.y-n2.y)*vn.y; % signed distance (dot product)
    
    % Compute csi given heading psi
    h.x = n1.x + cos(gps_psi);
    h.y = n1.y + sin(gps_psi);
    h.z = 0.0;

    % Compute vector from n1 to h
    k.x = h.x-n1.x;
    k.y = h.y-n1.y;
    k.z = 0.0;

    % Rotate
    temp = R'*[k.x; k.y; k.z];

    % Compute csi
    csi = atan2(temp(2),temp(1));
   
end