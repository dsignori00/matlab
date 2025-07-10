function co = get_color_order(u, n_colors)
if nargin < 1
    colors = [  0    0.4470    0.7410
                0.8500    0.3250    0.0980
                0.9290    0.6940    0.1250
                0.4940    0.1840    0.5560
                0.4660    0.6740    0.1880
                0.3010    0.7450    0.9330
                0.6350    0.0780    0.1840
                ];
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
        case 'rgb'
            colors( 1, :) = [ 1  0   0   ];
            colors( 2, :) = [ 0  1   0   ];
            colors( 3, :) = [ 0  0   1   ];
            colors( 4, :) = [ 1  0   1   ];
            colors( 5, :) = [ 0  0.8 0.8 ];
    end
end
if nargin == 2
    idx = floor(linspace(1,length(colors), n_colors));
    colors = colors(idx,:);
end
co = colors;
end

