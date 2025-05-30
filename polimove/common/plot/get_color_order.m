function co = get_color_order(u, n_colors)
% GET_COLOR_ORDER Returns a color order i.e. a Nx3 matrix where each row is
% a RGB color.
% INPUTS
% u         OPTIONAL String to identify the color order
%               Default: Matlab standard color order
%               y        Yellow color order
%               b        Blue color order
% n_colors  OPTIONAL number of colors in returned color order. Maximises
%           distance between the colors returned
%
%
% Author:   Luca Mozzarelli
% Version:  v2.0
% Date:     13/02/2021

if nargin < 1
    colors = [0.000, 0.447, 0.741;
          0.850, 0.325, 0.098;
          0.929, 0.694, 0.125;
          0.494, 0.184, 0.556;
          0.466, 0.674, 0.188;
          0.301, 0.745, 0.933;
          0.635, 0.078, 0.184];
else
    switch u
        case 'y'
            colors( 1, :) = [  55    6   6 ]/255;
            colors( 2, :) = [ 157    2   8 ]/255;
            colors( 3, :) = [ 208    0   0 ]/255;
            colors( 4, :) = [ 220   47   2 ]/255;
            colors( 5, :) = [ 232   93   4 ]/255;
            colors( 6, :) = [ 244  140   6 ]/255;
            colors( 7, :) = [ 250  163   7 ]/255;
            colors( 8, :) = [ 255  186   8 ]/255;
        case 'b'
            colors( 1, :) = [ 0   0   30  ]/255;
            colors( 2, :) = [ 3   4   94  ]/255;
            colors( 3, :) = [ 0   64  145 ]/255;
            colors( 4, :) = [ 0   119 182 ]/255;
            colors( 5, :) = [ 0   180 216 ]/255;
            colors( 6, :) = [ 92  213 237 ]/255;
            colors( 7, :) = [ 144 224 239 ]/255;
            colors( 8, :) = [ 202 240 248 ]/255;
    end
end
if nargin == 2
    idx = floor(linspace(1,length(colors), n_colors));
    colors = colors(idx,:);
end
co = colors;
end

