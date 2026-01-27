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

corr_value = abs(log_ref.rho);
corr_name  = 'range [m]';

%% CORRELATION
if ~search_correlations
    return;
end

corr_stamp = gt.stamp;

% Compute correlations for all sensors
for k = 1:length(sensors)
    s = sensors{k}.s;
    
    [R_x, P_x, R_y, P_y, ~, ...
        sensors{k}.s.sens_stamp, sensors{k}.s.x_map_err, sensors{k}.s.y_map_err] = ...
        corr_with_ref(s, corr_stamp, corr_value);
    
    % Store results for plotting
    sensors{k}.R_x = R_x;
    sensors{k}.P_x = P_x;
    sensors{k}.R_y = R_y;
    sensors{k}.P_y = P_y;
end

% Plotting
figure('Name','Correlations')
tiledlayout(3,1,'Padding','compact');

% 1) Reference signal
ax(f)=nexttile; hold on; grid on; f = f+1;
plot(corr_stamp, corr_value, 'DisplayName', corr_name)
title("Searching correlation with: " + corr_name)
ylabel(corr_name);
legend

% 2) X map errors
ax(f)=nexttile; hold on; grid on; f = f+1;
yline(0,'--k','LineWidth',0.3,'HandleVisibility','off')
for k = 1:length(sensors)
    s = sensors{k};
    p_str = sprintf('%.2e', s.P_x(2,1));
    plot_detections(s.s.sens_stamp, s.s.x_map_err, sensors{k}.s.max_det, sensors{k}.col, ['p=' p_str ' - ' s.name ]);
end
ylim(y_err_lim); legend show; ylabel('x map error [m]');

% 3) Y map errors
ax(f)=nexttile; hold on; grid on; f = f+1;
yline(0,'--k','LineWidth',0.3,'HandleVisibility','off')
for k = 1:length(sensors)
    s = sensors{k};
    p_str = sprintf('%.2e', s.P_y(2,1));
    plot_detections(s.s.sens_stamp, s.s.y_map_err, sensors{k}.s.max_det, sensors{k}.col, ['p=' p_str ' - ' s.name ]);
end
ylim(y_err_lim); legend show; ylabel('y map error [m]'); xlabel('timestamp [s]');
