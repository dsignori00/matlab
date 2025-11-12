function phl = PlotTrajDatabase(traj_DB, ax, legend_on, gray_scale, plot_pit)
%   PlotTrajDatabase: Plots all the trajectories in a poliMOVE IAC database
%   where db is a poliMOVE IAC trajectory database, and f is
%   a valid handle to an axis

%% VARARGS

if (nargin < 5)
    plot_pit = false;
end

%% PARAMETERS

apex_idx = 1:11;
non_apex_idx = 12:21;
traj_idx = [apex_idx, non_apex_idx];
pit_traj = 21;

%% VISUALIZATION SETTINGS
if gray_scale
%     lineWidth       = 0.5;
    lineWidth       = 1.0;
    apexColor       = [0.5 0.5 0.5];
    nonApexColor    = [0.2 0.2 0.2];
    pitColor        = [0.1 0.1 0.1];
%     nonApexStyle    = ':';
%     pitStyle        = '-.';
    nonApexStyle    = '--';
    ApexStyle       = '--';
    pitStyle        = '--';
else
    lineWidth       = 1;
    apexColor       = [0.3010 0.7450 0.9330];
    nonApexColor    = [1.0000 0.3921 0.3058];
    pitColor        = 'b';
    nonApexStyle    = '--';
    ApexStyle       = '--';
    pitStyle        = '-.';
end

%% PLOTTING TRAJ DB
phl=gobjects(length(traj_DB)-4,1);
% Plot trajectory database
for i=traj_idx
    x = [traj_DB(i).x; traj_DB(i).x(1)];
    y = [traj_DB(i).y; traj_DB(i).y(1)];
    phl(i) = plot(ax,x,y, 'LineWidth', lineWidth);
    if any(i == apex_idx)
        phl(i).Color = apexColor;
        phl(i).LineStyle = ApexStyle;
        phl(i).DisplayName = 'Apex Trajectory';
    else
        phl(i).Color = nonApexColor;
        phl(i).LineStyle = nonApexStyle;
        phl(i).DisplayName = 'Non-Apex Trajectory';
    end
    set(get(get(phl(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
% If the user wants the legend enable the first and last entry (should be one apex and one non-apex)
if legend_on
    set(get(get(phl(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
    set(get(get(phl(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
end

if plot_pit
    x = [traj_DB(pit_traj).x; traj_DB(pit_traj).x(1)];
    y = [traj_DB(pit_traj).y; traj_DB(pit_traj).y(1)];
    phl_pit = plot(ax,x,y, 'LineWidth', lineWidth);
    phl_pit.Color = pitColor;
    phl_pit.LineStyle = pitStyle;
    phl_pit.DisplayName = 'Apex Trajectory';
    set(get(get(phl_pit,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
end
