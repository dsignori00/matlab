function [x,y]=compute_fov(aper,center)

    center = deg2rad(center);
    ang = aper/2;
    x1 = linspace(0,100,1000)';
    y1 = x1*tan(deg2rad(ang))';

    x2 = x1;
    y2 = -y1;

    Rz = [cos(center), -sin(center);
          sin(center),  cos(center)];
    
    P1 = [x1,y1];
    P2 = [x2,y2];

    P1 = (Rz * P1')';
    P2 = (Rz * P2')';

    x1 = P1(:, 1);
    y1 = P1(:, 2);
    x2 = P2(:, 1);
    y2 = P2(:, 2);

    x = [x1;x2];
    y = [y1;y2];
    
end