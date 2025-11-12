function IACDefaultFigureSettings(interpreter)
if nargin < 1
    text_interpreter('tex')
else
    text_interpreter(interpreter);
    
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
end
