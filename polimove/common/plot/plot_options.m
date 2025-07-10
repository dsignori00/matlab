%% Plot useful data from .mat files
text_interpreter('latex');
set(0,'DefaultLineLinewidth',1.8)
set(0,'DefaultAxesFontSize',18)
set(0,'DefaultAxesXGrid','on',...
'DefaultAxesYGrid','on',...
'DefaultAxesZGrid','on')
set(0,'DefaultTextInterpreter', 'latex')
set(0,'DefaultFigureWindowStyle','docked')
set(0,'DefaultLegendFontSize',12)

warning('off','MATLAB:handle_graphics:exceptions:SceneNode') %no warning for error updating text
warning('off','Control:analysis:LsimStartTime')         % no warning for nonzero time simulations

%% JD graphics options
run('graphics_options.m');
