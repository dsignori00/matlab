%% Plot default 
set(0,'DefaultLineLinewidth',2.5);
set(0,'DefaultAxesFontSize',16);
set(0,'DefaultLegendFontSize',16);
set(0, 'DefaultAxesBox', 'on');
%set(0,'PaperPositionMode','auto');
set(0,'DefaultAxesFontName','Times New Roman');

 set(0,'DefaultAxesXGrid','on',...
 'DefaultAxesYGrid','on',...
 'DefaultAxesZGrid','on')


set(0,'DefaultTextInterpreter', 'latex')
set(0,'DefaultLegendInterpreter', 'latex')
set(0,'DefaultFigureWindowStyle','docked') %normal 'stacked'

set(0,'defaultAxesXMinorGrid','on','defaultAxesXMinorGridMode','manual');
%set(0,'defaultAxesYMinorGrid','on','defaultAxesYMinorGridMode','manual');

warning('off','MATLAB:handle_graphics:exceptions:SceneNode') %no warning for error updating text

warning('off','Control:analysis:LsimStartTime')         % no warning for nonzero time simulations

%% My colormap

% cc=lines(6);
% 
% length_cm = 3;
% color_1 = [0, 0.2, 0.5];
% color_2 = [0.5, 0.7, 0.9];
% my_colormap= [linspace(color_1(1),color_2(1),length_cm)', linspace(color_1(2),color_2(2),length_cm)', linspace(color_1(3),color_2(3),length_cm)'];
% 
% % length_cm = 8;
% % color_1 = [0, 0.2, 0.5];
% % color_2 = [0.7, 0.8, 0.9];
% % cs= [linspace(color_1(1),color_2(1),length_cm)', linspace(color_1(2),color_2(2),length_cm)', linspace(color_1(3),color_2(3),length_cm)'];
% 
% length_cm = 2;
% color_1 = [0, 0.2, 0.5];
% color_2 = [0.2, 0.6, 0.6];
% my_colormap2= [linspace(color_1(1),color_2(1),length_cm)', linspace(color_1(2),color_2(2),length_cm)', linspace(color_1(3),color_2(3),length_cm)'];
% 
% 
% 
% c_est=[0.30,0.75,0.93];
% c_meas=[0.09,0.17,0.50];
% c_bench=[1.00,0.00,0.00];