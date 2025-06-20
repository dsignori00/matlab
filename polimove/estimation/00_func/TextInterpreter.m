function text_interpreter(interpreter)
%TEXT_INTERPRETER Modifies default text interpreter
%
% Pass interpreter='latex' to set all text objects in a figure to latex
% Any other parameter will reset to default 'tex' mode
if strcmp(interpreter, 'latex') == 1
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    set(groot, 'defaultTextInterpreter','latex');
else
    set(groot, 'defaultAxesTickLabelInterpreter','tex');
    set(groot, 'defaultLegendInterpreter','tex');
    set(groot, 'defaultTextInterpreter','tex');
end

% Shows all the factory values for all object properties.
% get(groot, 'factory');
% Shows only altered default values
% get(groot, 'default'); 
end