function nm = figure_name(tag)
    switch tag
        case 'traj',  nm = 'Trajectory';
        case 'speed', nm = 'Speed Profile';
        case 'acc',   nm = 'Acceleration Profile';
        case 'gg',    nm = 'GG Plot';
    end
end