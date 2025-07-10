function rect = rettangolo(point,w,h,theta)
    rot_m = RotMat2d(theta);
    rect_vertex = [ [w/2 w/2 -w/2 -w/2]' [-h/2 h/2 h/2 -h/2]' ];
    rect_vertex = (rot_m*rect_vertex')';
    
    rect_vertex(:,1) = rect_vertex(:,1) + point(1);
    rect_vertex(:,2) = rect_vertex(:,2) + point(2);
    
    rect = polyshape(rect_vertex(:,1),rect_vertex(:,2));
end
