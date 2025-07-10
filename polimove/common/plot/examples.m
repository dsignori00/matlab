
clc
close all
clearvars

%% SETTINGS

run('graphics_options.m');

%% EXAMPLES

my_colors = color_spacer(20);

figure; hold on;
for i = 1:length(my_colors)
    plot([0 1], [0 1]+i, 'color', my_colors{i});
end

figure; hold on;
for i = 1:length(colors.matlab)
    plot([0 1], [0 1]+i, 'color', colors.matlab{i});
end

figure; hold on;
my_colors = color_tints_and_shades(colors.matlab{1}, 10, 0.5);
for i = 1:length(my_colors)
    plot([0 1], [0 1]+i, 'color', my_colors{i});
end

figure; hold on;
my_colors = color_shades_brightness(colors.matlab{1}, 10, 0.5);
for i = 1:length(my_colors)
    plot([0 1], [0 1]+i, 'color', my_colors{i});
end

figure; hold on;
my_colors = color_shades_saturation(colors.matlab{1}, 10, 0.5);
for i = 1:length(my_colors)
    plot([0 1], [0 1]+i, 'color', my_colors{i});
end

figure; hold on;
for i = 1:length(colors.red)
    plot([0 1], [0 1]+i, 'color', colors.red{i});
end