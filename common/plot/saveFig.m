function [] = saveFig(name,figHeight)
% --- Configuration ---
figWidth = 8.89;  % cm (typical single column)
% figHeight = 3.5; % cm
fontSize = 8;    % pt
% --- Apply Formatting ---
fig=gcf;
set(fig, 'Units', 'centimeters', 'Position', [0, 2, figWidth, figHeight]);
set(findall(fig, '-property', 'FontSize'), 'FontSize', fontSize);
set(findall(fig, '-property', 'FontName'), 'FontName', 'Times New Roman');
% --- Export to PDF ---
exportgraphics(fig, strcat(name,'.pdf'), 'ContentType', 'vector');
end