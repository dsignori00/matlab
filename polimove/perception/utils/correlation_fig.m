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


if(src_corr)
    % Speed
    corr_stamp = gt.stamp;
    corr_value = abs(log_ref.rho);
    corr_name = 'Opp distance';
    
    
    % Variable interpolation
    lid_clust.sens_stamp = lid_clust.sens_stamp(~isnan(lid_clust.x_map_err));
    lid_clust.x_map_err = lid_clust.x_map_err(~isnan(lid_clust.x_map_err));
    lid_clust.y_map_err = lid_clust.y_map_err(~isnan(lid_clust.y_map_err));
    for i = 1 : length(lid_clust.sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,lid_clust.sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,lid_clust.sens_stamp,'linear','extrap'); 
    end
    corr_with_x_map(end) = 0;
    corr_with_y_map(end) = 0;
    [R_x_lid_clust,P_x_lid_clust] = corrcoef(corr_with_x_map,abs(lid_clust.x_map_err));
    [R_y_lid_clust,P_y_lid_clust] = corrcoef(corr_with_y_map,abs(lid_clust.y_map_err));
    
    
    lid_pp.sens_stamp = lid_pp.sens_stamp(~isnan(lid_pp.x_map_err));
    lid_pp.x_map_err = lid_pp.x_map_err(~isnan(lid_pp.x_map_err));
    lid_pp.y_map_err = lid_pp.y_map_err(~isnan(lid_pp.y_map_err));
    for i = 1 : length(lid_pp.sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,lid_pp.sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,lid_pp.sens_stamp,'linear','extrap'); 
    end
    [R_x_lid_pp,P_x_lid_pp] = corrcoef(corr_with_x_map,abs(lid_pp.x_map_err));
    [R_y_lid_pp,P_y_lid_pp] = corrcoef(corr_with_y_map,abs(lid_pp.y_map_err));
    
    rad_clust.sens_stamp = rad_clust.sens_stamp(~isnan(rad_clust.x_map_err));
    rad_clust.x_map_err = rad_clust.x_map_err(~isnan(rad_clust.x_map_err));
    rad_clust.y_map_err = rad_clust.y_map_err(~isnan(rad_clust.y_map_err));
    for i = 1 : length(rad_clust.sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,rad_clust.sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,rad_clust.sens_stamp,'linear','extrap'); 
    end
    [R_x_rad_clust,P_x_rad_clust] = corrcoef(corr_with_x_map,abs(rad_clust.x_map_err));
    [R_y_rad_clust,P_y_rad_clust] = corrcoef(corr_with_y_map,abs(rad_clust.y_map_err));
    
    cam_yolo.sens_stamp = cam_yolo.sens_stamp(~isnan(cam_yolo.x_map_err));
    cam_yolo.x_map_err = cam_yolo.x_map_err(~isnan(cam_yolo.x_map_err));
    cam_yolo.y_map_err = cam_yolo.y_map_err(~isnan(cam_yolo.y_map_err));
    for i = 1 : length(cam_yolo.sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,cam_yolo.sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,cam_yolo.sens_stamp,'linear','extrap'); 
    end
    [R_x_cam_yolo,P_x_cam_yolo] = corrcoef(corr_with_x_map,abs(cam_yolo.x_map_err));
    [R_y_cam_yolo,P_y_cam_yolo] = corrcoef(corr_with_y_map,abs(cam_yolo.y_map_err));
    
    
    figure('Name','Correlations')
    tiledlayout(3,1,'Padding','compact');
    
    axes(f) = nexttile;
    f = f+1;
    hold on;
    grid on;
    plot(corr_stamp,corr_value,'DisplayName',string(corr_name))
    title('Searching correlation with: '+string(corr_name))
    
    axes(f) = nexttile;
    f = f+1;
    hold on;
    grid on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3,'HandleVisibility','off');
    plot(lid_clust.sens_stamp, lid_clust.x_map_err, '*', 'Color', col.lidar,'DisplayName', ['Lidar Clust - p value: ' num2str(P_x_lid_clust(2,1))]);
    plot(rad_clust.sens_stamp,rad_clust.x_map_err,'*','Color',col.radar,'DisplayName', ['Radar Clust - p value: ' num2str(P_x_rad_clust(2,1))]);
    plot(lid_pp.sens_stamp,lid_pp.x_map_err,'*','Color',col.pointpillars,'DisplayName',['Lidar PP - p value: ' num2str(P_x_lid_pp(2,1))]);
    plot(cam_yolo.sens_stamp,cam_yolo.x_map_err,'*','Color',col.camera, 'DisplayName',['Camera - p value: ' num2str(P_x_cam_yolo(2,1))]);
    title('Detection Error - x map')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    legend('Location','northwest')
    
    axes(f) = nexttile;
    f = f+1;
    hold on;
    grid on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3,'HandleVisibility','off');
    plot(lid_clust.sens_stamp,lid_clust.y_map_err,'*','Color',col.lidar,'DisplayName',['Lidar Clust - p value: ' num2str(P_y_lid_clust(2,1))]);
    plot(rad_clust.sens_stamp,rad_clust.y_map_err,'*','Color',col.radar,'DisplayName',['Radar Clust - p value: ' num2str(P_y_rad_clust(2,1))]);
    plot(lid_pp.sens_stamp,lid_pp.y_map_err,'*','Color',col.pointpillars,'DisplayName',['Lidar PP - p value: ' num2str(P_y_lid_pp(2,1))]);
    plot(cam_yolo.sens_stamp,cam_yolo.y_map_err,'*','Color',col.camera,'DisplayName',['Camera - p value: ' num2str(P_y_cam_yolo(2,1))]);
    title('Detection Error - y map')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    legend('Location','northwest')
    
    linkaxes(axes,'x')
end