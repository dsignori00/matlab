function Rotm = RotMat2d(theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                         
%         poliMove - IAC - 2dRotMat                                       %                                                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision: 1                                                             %
% Author: Filippo Parravicini                                             %
% Date: YYYY.MM.DD                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brief summary of the function 
% Input: - Theta: rotation angle in radians
%
% Output:- Rotm: rotation matrix of the form
%               Rotm = [cos(theta) sin(theta)
%                      -sin(theta) cos(theta)];
%

Rotm = [cos(theta) -sin(theta);
        sin(theta) cos(theta)];
end

