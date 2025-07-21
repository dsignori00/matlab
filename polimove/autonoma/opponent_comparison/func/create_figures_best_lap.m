function [fig, panel, checkbox] = create_figures_best_lap(name, checklist_strings, default_selection, tag)
    fig = figure('Name', name);
    panel = uipanel('Parent', fig, ...
        'Units','normalized', ...
        'Position',[0.02 0.1 0.12 0.8], ...
        'Title','Controls');

    checkbox = create_opponent_checkboxes(panel, checklist_strings, default_selection, tag);

end
