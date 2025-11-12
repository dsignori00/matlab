colors.matlab = hex2rgb({'#0072BD'; '#D95319'; '#EDB120'; '#7E2F8E'; '#77AC30'; '#4DBEEE'; '#A2142F'});
colors.matlab = [colors.matlab; colors.matlab; colors.matlab];
colors.grey = {[1 1 1]*0.85; [1 1 1]*0.7; [1 1 1]*0.55; [1 1 1]*0.4; [1 1 1]*0.25; [1 1 1]*0.1};
colors.white = [1 1 1];
colors.black = [0 0 0];
colors.blue = color_tints_and_shades(colors.matlab{1}, 3, 0.5);
colors.orange = color_tints_and_shades(colors.matlab{2}, 3, 0.5);
colors.yellow = color_tints_and_shades(colors.matlab{3}, 3, 0.5);
colors.purple = color_tints_and_shades(colors.matlab{4}, 3, 0.5);
colors.green = color_tints_and_shades(colors.matlab{5}, 3, 0.5);
colors.red = color_tints_and_shades([0.7466    0.1371    0.2981], 3, 0.5);
colors.crayon = color_spacer(5);
colors.crayon = [colors.crayon; colors.crayon; colors.crayon];
colors.brembo = [0.6353    0.0784    0.1843];

colors.rod = hex2rgb({'#118ab2'; '#ffb703'; '#02c39a'; '#d62828'; '#4f518c'; '#ef476f'});
colors.blue_rod = color_tints_and_shades(colors.rod{1}, 3, 0.5);
colors.yellow_rod = color_tints_and_shades(colors.rod{2}, 3, 0.5);
colors.green_rod = color_tints_and_shades(colors.rod{3}, 3, 0.5);
colors.red_rod = color_tints_and_shades(colors.rod{4}, 3, 0.5);
colors.purple_rod = color_tints_and_shades(colors.rod{5}, 3, 0.5);
colors.majin_rod = color_tints_and_shades(colors.rod{6}, 3, 0.5);
set(groot,'defaultAxesFontSize',16);
set(groot,'defaultTextFontSize',16);
set(groot,'defaultAxesFontName','latex');
set(groot,'defaultTextFontName','latex');
set(groot,'DefaultAxesBox','on');
set(groot,'DefaultAxesXGrid','on');
set(groot,'DefaultAxesYGrid','on');
set(groot,'DefaultLineLinewidth',2);
set(groot, 'DefaultStairLineWidth', 2);
set(0,'DefaultFigureWindowStyle','docked');

set(0, 'defaultAxesTickLabelInterpreter','latex');      % Axes tick label
set(0, 'defaultLegendInterpreter','latex');             % Legend
set(0, 'defaultTextInterpreter','latex');               % Miscellaneous strings
set(0, 'defaultColorBarTickLabelInterpreter', 'latex'); % Color bar ticks