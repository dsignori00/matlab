function color = get_color(u, co)
% GET_COLOR Provides easy access to matlab default colors, plus some bonus
% When u is one of the recognized strings, returns the related color.
% When it is a number "i" it returns i-th color in the color order passed
% as second argument.
% Second argument is an optional color order ( Nx3 matrix with RGB values
% on each row). Defaults to Matlab default color scheme.
%
% COLOR STRINGS
% b     blue
% o     orange
% y     yellow
% v     violet
% g     green
% lb    light blue
% m     maroon
% gr    gray (70 %)
% 
% Author:   Luca Mozzarelli
% Version:  v2.0
% Date:     13/02/2021

if nargin < 2
    co = [0.000, 0.447, 0.741;
          0.850, 0.325, 0.098;
          0.929, 0.694, 0.125;
          0.494, 0.184, 0.556;
          0.466, 0.674, 0.188;
          0.301, 0.745, 0.933;
          0.635, 0.078, 0.184];
end
if isa(u, 'numeric')
    color = co(u,:);
else
    switch u
        case {'blue', 'b'}
            color = co(1,:);
        case {'orange', 'o'}
            color = co(2,:);
        case {'yellow', 'y'}
            color = co(3,:);
        case {'violet', 'v'}
            color = co(4,:);
        case {'green', 'g'}
            color = co(5,:);
        case {'light blue', 'sky', 'lb'}
            color = co(6,:);
        case {'maroon', 'm'}
            color = co(7,:);
        case {'gray', 'gr'}
            color = [0.7 0.7 0.7];
        case {'black', 'k'}
            color = [0.0 0.0 0.0];
    end
end
end