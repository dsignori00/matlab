function path = get_bags_dir()
    proj = currentProject();

    if strcmp(proj.Name, 'polimove')
        path = fullfile(proj.RootFolder, 'bags');
    else
        error('Unknown project: %s', proj.Name);
    end
end