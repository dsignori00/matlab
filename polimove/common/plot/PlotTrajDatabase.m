function phl = plotTrajDatabase(traj_DB, ax, legend_on)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         poliMove - IAC - plotTrajDatabase                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision: 2                                                             %
% Author: Eugenio Favuzzi                                                 %
% Date: 2021.02.27                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   PlotTrajDatabase: Plots all the trajectories in a poliMOVE IAC database
%   where db is a poliMOVE IAC trajectory database, and f is
%   a valid handle to an axis

    phl=gobjects(length(traj_DB.pages),1);
    % Plot trajectory database
    for i=1:length(traj_DB.pages)
        x = [traj_DB.pages(i).TrajCoords.X; traj_DB.pages(i).TrajCoords.X(1)];
        y = [traj_DB.pages(i).TrajCoords.Y; traj_DB.pages(i).TrajCoords.Y(1)];
        phl(i) = plot(ax,x,y, 'LineWidth', 1);
%         scatter(ax,x,y)
        
        if traj_DB.pages(i).ApexTrajFlag
            phl(i).Color = [0.3010 0.7450 0.9330];
            hl(i).LineStyle = '-';
            phl(i).DisplayName = 'Apex Trajectory';
        else
            phl(i).Color = [1.0000 0.3921 0.3058];
            phl(i).LineStyle = '--';
            phl(i).DisplayName = 'Non-Apex Trajectory';
        end
        set(get(get(phl(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    % If the user wants the legend enable the first and last entry (should be one apex and one non-apex)
    if legend_on
        set(get(get(phl(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
        set(get(get(phl(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
    end
end
