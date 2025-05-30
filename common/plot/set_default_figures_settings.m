function varargout = set_default_figures_settings(interpreter, window_style)
if nargin < 1
    text_interpreter('tex')
else
    text_interpreter(interpreter);
end

if nargin < 2
  window_style = 'normal';
end
  

set(0, 'DefaultAxesBox','on')
set(0, 'DefaultAxesXGrid','on')
set(0, 'DefaultAxesYGrid','on')
set(0, 'DefaultAxesXMinorGrid','on')
set(0, 'DefaultAxesYMinorGrid','on')
set(0, 'DefaultAxesXMinorGridMode','manual');
set(0, 'DefaultAxesYMinorGridMode','manual');

set(0, 'DefaultAxesFontSize',15)

set(0, 'DefaultLineMarkerSize', 8);
set(0, 'DefaultLineLineWidth', 1.5);

set(0, 'DefaultFigureWindowStyle', window_style);

% Return default colors
varargout{1} = lines(6);
end
