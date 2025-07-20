function nm = figure_name(tag)
    switch tag
        case 'traj', nm = 'Trajectory';
        case 'speed', nm = 'Speed Profile';
        case 'curv', nm = 'Acceleration Profile';
    end
end