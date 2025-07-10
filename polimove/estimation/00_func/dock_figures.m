function dock_figures(active)
%DOCK_FIGURES Toggles figures docking
if nargin == 0
    curr = get(0, 'DefaultFigureWindowStyle');
    if strcmp(curr, 'docked')
        set(0, 'DefaultFigureWindowStyle', 'normal');
%         disp("Figures are now undocked and sailing the 7 seas");
    else
        set(0, 'DefaultFigureWindowStyle', 'docked');
%         disp("Figures are now docked");
    end
elseif nargin == 1
    if strcmp(active,'on')
        set(0, 'DefaultFigureWindowStyle', 'docked');
%         disp("Figures are now docked");
    elseif strcmp(active,'off')
        set(0, 'DefaultFigureWindowStyle', 'normal');
%         disp("Figures are now undocked and sailing the 7 seas");
    else
        error('Unrecognized argument :(');
    end
end
end

