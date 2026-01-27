%% CORRELATION

% Remember that:
% p-value: The probability of obtaining test results at least as extreme as
%          the result actually observed, under the assumption that the null
%          hypothesis is correct
%
% r coeff: The correlation coefficient is the specific measure that 
%          quantifies the strength of the linear relationship between 
%          two variables in a correlation analysis. Positive r values
%          indicate a positive correlation, where the values of both 
%          variables tend to increase together.


%% CORRELATION
if search_correlations

    corr_stamp = gt.stamp;
    corr_value = abs(log_ref.rho);
    corr_name  = 'Opp distance';

    % Compute correlations
    [R_x_lid_clust,P_x_lid_clust,R_y_lid_clust,P_y_lid_clust,~, ...
        lid_clust.sens_stamp,lid_clust.x_map_err,lid_clust.y_map_err] = ...
        corr_with_ref(lid_clust, corr_stamp, corr_value);

    [R_x_lid_pp,P_x_lid_pp,R_y_lid_pp,P_y_lid_pp,~, ...
        lid_pp.sens_stamp,lid_pp.x_map_err,lid_pp.y_map_err] = ...
        corr_with_ref(lid_pp, corr_stamp, corr_value);

    [R_x_rad_clust,P_x_rad_clust,R_y_rad_clust,P_y_rad_clust,~, ...
        rad_clust.sens_stamp,rad_clust.x_map_err,rad_clust.y_map_err] = ...
        corr_with_ref(rad_clust, corr_stamp, corr_value);

    [R_x_cam_yolo,P_x_cam_yolo,R_y_cam_yolo,P_y_cam_yolo,~, ...
        cam_yolo.sens_stamp,cam_yolo.x_map_err,cam_yolo.y_map_err] = ...
        corr_with_ref(cam_yolo, corr_stamp, corr_value);

            figure('Name','Correlations')
    tiledlayout(3,1,'Padding','compact');

    nexttile; hold on; grid on;
    plot(corr_stamp, corr_value, 'DisplayName', corr_name)
    title("Searching correlation with: " + corr_name)
    legend

    nexttile; hold on; grid on;
    yline(0,'--k','LineWidth',0.3,'HandleVisibility','off')
    plot(lid_clust.sens_stamp,lid_clust.x_map_err,'*','Color',col.lidar, ...
        'DisplayName',['Lidar Clust - p=' num2str(P_x_lid_clust(2,1))])
    plot(rad_clust.sens_stamp,rad_clust.x_map_err,'*','Color',col.radar, ...
        'DisplayName',['Radar Clust - p=' num2str(P_x_rad_clust(2,1))])
    plot(lid_pp.sens_stamp,lid_pp.x_map_err,'*','Color',col.pp, ...
        'DisplayName',['Lidar PP - p=' num2str(P_x_lid_pp(2,1))])
    plot(cam_yolo.sens_stamp,cam_yolo.x_map_err,'*','Color',col.camera, ...
        'DisplayName',['Camera - p=' num2str(P_x_cam_yolo(2,1))])
    title('Detection Error - x map')
    ylim([-gat_thr gat_thr])
    legend('Location','northwest')

    nexttile; hold on; grid on;
    yline(0,'--k','LineWidth',0.3,'HandleVisibility','off')
    plot(lid_clust.sens_stamp,lid_clust.y_map_err,'*','Color',col.lidar, ...
        'DisplayName',['Lidar Clust - p=' num2str(P_y_lid_clust(2,1))])
    plot(rad_clust.sens_stamp,rad_clust.y_map_err,'*','Color',col.radar, ...
        'DisplayName',['Radar Clust - p=' num2str(P_y_rad_clust(2,1))])
    plot(lid_pp.sens_stamp,lid_pp.y_map_err,'*','Color',col.pp, ...
        'DisplayName',['Lidar PP - p=' num2str(P_y_lid_pp(2,1))])
    plot(cam_yolo.sens_stamp,cam_yolo.y_map_err,'*','Color',col.camera, ...
        'DisplayName',['Camera - p=' num2str(P_y_cam_yolo(2,1))])
    title('Detection Error - y map')
    ylim([-gat_thr gat_thr])
    legend('Location','northwest')
end
