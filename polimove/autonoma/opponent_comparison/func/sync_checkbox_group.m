function sync_checkbox_group(figH, selIdx)
    % Force the check-boxes in figH to reflect selIdx
    if isempty(figH), return; end
    cbs = getappdata(figH,'checklist');
    for k = 1:numel(cbs)
        cbs(k).Value = ismember(k, selIdx);
    end
end