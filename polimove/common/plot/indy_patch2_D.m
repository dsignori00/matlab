function [Xpatch,Ypatch]=IndyPatch2D(X,Y,Yaw,flag)
% From vehicle position and orientation compute bounding rectangle
% X                 [m] Vehicle position X (geometric center or base frame)
% Y                 [m] Vehicle position Y (geometric center or base frame)
% Yaw               [m] Vehicle yaw angle
% flag_geometric        (REMOVED)Flag to specify if the position is referred to the
%                       vehicle base frame (false, default) or to its
%                       geometric center (true)

load('indy_patch_v2.mat');
Yaw  = Yaw-pi/2;
R=[cos(Yaw),-sin(Yaw);sin(Yaw),cos(Yaw)];
M=R*M;
Ypatch=M(2,:)+Y;
Xpatch=M(1,:)+X;
Xpatch = [Xpatch,Xpatch(1)];
Ypatch = [Ypatch,Ypatch(1)];
end