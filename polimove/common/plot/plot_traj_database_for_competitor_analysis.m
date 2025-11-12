%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         poliMove - IAC - plotTrajDatabase                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision: 1                                                             %
% Author: Eugenio Favuzzi                                                 %
% Edited by: Marcello Cellina                                             %
% Date: 2021.03.01                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PlotTrajDatabase Plots all the trajectories in a poliMOVE IAC database
%   where db is a poliMOVE IAC trajectory database, and f is
%   a handle to a figure. It plots all the trajectories in the database.
    
    
function plotTrajDatabase(traj_DB, f, heat)
%% ADD PATHS
addpath('../../05_Tools\00_func')
indy_path = get_indy_path();
track_path = (indy_path + '10_Specs' + filesep + '02_Simu_Track'+ filesep + 'indytrackdata.mat');
%% LOAD TRACK
track = load(track_path);

%% PLOT
shl_map = subplot(1, 1, 1);
    
    % Plot track limits
    internal = plot(shl_map, track.track_line0(:,1),track.track_line0(:,2),'-k','LineWidth',4);hold on;
    external = plot(shl_map, track.track_line5(:,1),track.track_line5(:,2),'-k','LineWidth',4);hold on;
    set(get(get(internal,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(external,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    
    % Plot trajectory database
    for i=1:length(traj_DB.trajectories)
        p(i) = plot(traj_DB.trajectories(i).TrajCoords.X, traj_DB.trajectories(i).TrajCoords.Y, 'LineWidth', 1);
        p(i).DisplayName = traj_DB.trajectories(i).Team; 
        if heat
            rel_t=traj_DB.trajectories(i).Rel_Time*2;
            if strcmp(traj_DB.trajectories(i).Team,'Abhyaan')|| strcmp(traj_DB.trajectories(i).Team,'MIT PITT')|| strcmp(traj_DB.trajectories(i).Team,'Pegasus')
                p(i).Color = [1 0 0];
            else
                p(i).Color = [rel_t 0 1-rel_t];
            end
        else
            p(i).Color = traj_DB.trajectories(i).Colour;

        end
    end
    if strcmp(f.Name,'Legend')
        l=legend(traj_DB.trajectories(:).Team,'NumColumns',2);
        saveLegendToImage(f, l, 'legend', 'png');
    end
end

function saveLegendToImage(figHandle, legHandle, ...
fileName, fileType)

%%https://stackoverflow.com/questions/18117664/how-can-i-show-only-the-legend-in-matlab

%make all contents in figure invisible
allLineHandles = findall(figHandle, 'type', 'line');

for i = 1:length(allLineHandles)

    allLineHandles(i).XData = NaN; %ignore warnings

end

%make axes invisible
axis off

%move legend to lower left corner of figure window
legHandle.Units = 'pixels';
boxLineWidth = legHandle.LineWidth;
%save isn't accurate and would swallow part of the box without factors
legHandle.Position = [6 * boxLineWidth, 6 * boxLineWidth, ...
    legHandle.Position(3), legHandle.Position(4)];
legLocPixels = legHandle.Position;

%make figure window fit legend
figHandle.Units = 'pixels';
figHandle.InnerPosition = [1, 1, legLocPixels(3) + 12 * boxLineWidth, ...
    legLocPixels(4) + 12 * boxLineWidth];

%save legend
saveas(figHandle, [fileName, '.', fileType], fileType);

end

