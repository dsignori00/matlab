function path = get_gt_dir()
    proj = currentProject();

    if strcmp(proj.Name, 'polimove')
        path = fullfile(proj.Root, 'src', 'perception', 'opponent_gps', 'mat');
    else
        error('Unknown project: %s', proj.Name);
    end
end