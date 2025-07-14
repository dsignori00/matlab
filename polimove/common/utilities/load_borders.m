function [left_border, right_border] = load_borders(track_name)

    left_border = load(fullfile('..', 'mat', 'tracks', track_name, 'left_border.mat')).points;
    right_border = load(fullfile('..', 'mat', 'tracks', track_name, 'right_border.mat')).points;

end

