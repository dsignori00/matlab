function [Xpatch,Ypatch]=vehiclePatch2D(X,Y,Yaw,flag_geometric)
% From vehicle position and orientation compute bounding rectangle
% X                 [m] Vehicle position X (geometric center or base frame)
% Y                 [m] Vehicle position Y (geometric center or base frame)
% Yaw               [m] Vehicle yaw angle
% flag_geometric        Flag to specify if the position is referred to the
%                       vehicle base frame (false, default) or to its
%                       geometric center (true)

if nargin > 3 && flag_geometric
    % Using geometric center coordinates
    DeltaFront =  2.5;
    DeltaRear  = -2.5;
else
    DeltaFront =  4.28;
    DeltaRear  = -0.72;
end
DeltaSide  = 1;
    
% counterclockwise from top left
chamfer = 0.75;
XY_unrot=[DeltaRear, DeltaRear,  DeltaFront-chamfer,  DeltaFront,        DeltaFront,        DeltaFront-chamfer;
          DeltaSide,-DeltaSide, -DeltaSide,          -DeltaSide+chamfer, DeltaSide-chamfer, DeltaSide];
R=[cos(Yaw),-sin(Yaw);sin(Yaw),cos(Yaw)];
XY_rot=R*XY_unrot;
Xpatch=XY_rot(1,:)+X;
Ypatch=XY_rot(2,:)+Y;
Xpatch = [Xpatch,Xpatch(1)];
Ypatch = [Ypatch,Ypatch(1)];
end