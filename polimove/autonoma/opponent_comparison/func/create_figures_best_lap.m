function [fig, panel, checkbox, popup_ego, popup_opp] = create_figures_best_lap(name, checklist_strings, default_selection, v2v, ego, tag, ego_vs_ego)
    if(ego_vs_ego)
        [fig, panel, checkbox, popup_ego, popup_opp] = ...
            create_figures(name, checklist_strings, default_selection, v2v, ego, tag, ego_vs_ego);
            return;
    end
    fig = figure('Name', name);
    panel = uipanel('Parent', fig, ...
        'Units','normalized', ...
        'Position',[0.02 0.1 0.12 0.8], ...
        'Title','Controls');

    checkbox = create_opponent_checkboxes(panel, checklist_strings, default_selection, tag);

    popup_ego = [];
    popup_opp = [];
end
