function [fig, panel, checkbox, popup_ego, popup_opp] = create_figures(name, checklist_strings, default_selection, v2v, ego, tag, ego_vs_ego)
    fig = figure('Name', name);
    panel = uipanel('Parent', fig, ...
        'Units','normalized', ...
        'Position',[0.02 0.1 0.12 0.8], ...
        'Title','Controls');

    checkbox = create_opponent_checkboxes(panel, checklist_strings, default_selection, tag);

    max_lap = max(v2v.laps(:), [], 'omitnan');
    max_lap_ego = max(ego.laps(:), [], 'omitnan');

    % Layout calc
    base_height_per_opp = 0.05;
    checklist_height = min(base_height_per_opp * numel(checkbox) + 0.1, 0.9);
    nextY = 1 - checklist_height - 0.08;

    % Opponent lap
    opp_label = "Opponent Lap:";
    if (ego_vs_ego)
        opp_label = "Ego 2 Lap:";
    end
    uicontrol('Parent', panel, 'Style', 'text', 'String', opp_label, ...
        'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
    nextY = nextY - 0.04;
    popup_opp = uicontrol('Parent', panel, 'Style', 'popupmenu', ...
        'String', compose("Lap %d", 1:max_lap), ...
        'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
        'Callback', @(src,evt) update_lap_selection(src,evt,'opp'));
    nextY = nextY - 0.05;

    % Ego lap
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Ego Lap:', ...
        'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
    nextY = nextY - 0.04;
    popup_ego = uicontrol('Parent', panel, 'Style', 'popupmenu', ...
        'String', compose("Lap %d", 1:max_lap_ego), ...
        'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
        'Callback', @(src,evt) update_lap_selection(src,evt,'ego'));
end
