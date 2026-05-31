function phl = plot_traj_database2025(traj_DB, legend_on, grayScaleOn)

%% VISUALIZATION SETTINGS
figure;       
ax = axes;    
hold(ax, 'on'); 
grid(ax, 'on');
lineWidth       = 0.5;

    if grayScaleOn
        apexColor       = [0.5 0.5 0.5];
        nonApexColor    = [0.2 0.2 0.2];
        pitColor        = [0.2 0.2 0.2];
        nonApexStyle    = ':';
        pitStyle        = ':';
    else
        apexColor       = [1.0000 0.0000 0.0000];
        nonApexColor    = [0.5000 0.5000 0.5000];
        pitColor        = [0.0000 0.0000 1.0000];
        nonApexStyle    = '--';
        pitStyle        = '-.';
    end
    
%% PLOTTING TRAJ DB
    phl=gobjects(length(traj_DB),1);
    % Plot trajectory database
    for i=1:length(traj_DB)
        x = [traj_DB(i).X; traj_DB(i).X(1)];
        y = [traj_DB(i).Y; traj_DB(i).Y(1)];
        phl(i) = plot(ax,x,y, 'LineWidth', lineWidth);
        if i==10
            phl(i).Color = apexColor;
            phl(i).LineWidth = 2;
            phl(i).DisplayName = 'Apex Trajectory';
        elseif i==22 
            phl(i).Color = pitColor;
            phl(i).LineStyle = pitStyle;            
            phl(i).DisplayName = 'Pit Trajectory';
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
    axis equal
end