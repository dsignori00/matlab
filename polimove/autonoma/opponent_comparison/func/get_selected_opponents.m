function sel = get_selected_opponents(figH)
    % Return index vector of selected opponents for a given figure
    cbs = getappdata(figH,'checklist');
    sel = find(arrayfun(@(h) get(h,'Value'), cbs));
end