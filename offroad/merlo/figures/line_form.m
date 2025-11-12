%% Animated GIFs: Parallel lines using normal form with exact [m,q]
close all; clc; clearvars;

% Parameters
num_lines = 5;
spacing = 1.5;           
offset = 0.5;
rho_vals = linspace(-spacing*(num_lines-1)/2+offset, spacing*(num_lines-1)/2+offset, num_lines);

x = linspace(-5,5,200);  % x-values for plotting
colors = lines(num_lines);

% Angles to animate: horizontal (theta=0) to vertical (theta=pi/2)
theta_vals_anim = linspace(pi/2-0.01, 0.01, 60); % from vertical to horizontal

%% GIF filenames
plot_gif = 'lines_normal_animation.gif';
scatter_gif = 'scatter_normal_animation.gif';

%% Loop through angles
for k = 1:length(theta_vals_anim)
    theta = theta_vals_anim(k);
    
    % ---------- Plot of lines ----------
    fig1 = figure(1); clf; hold on; axis equal; grid on;
    xlabel('x'); ylabel('y'); title('Parallel lines changing angle \theta');
    
    % Draw lines in normal form
    for j = 1:num_lines
        rho = rho_vals(j);
        y = (rho - x*cos(theta))/sin(theta);
        plot(x,y,'Color',colors(j,:),'LineWidth',1.5);
    end
    
    % Guidelines: axes
    xline(0,'k--','LineWidth',1);
    yline(0,'k--','LineWidth',1);
    
    % Semicircles
    radii = 2:1:8;
    theta_circ = linspace(0,2*pi,200);
    for r = radii
        [xc, yc] = pol2cart(theta_circ,r);
        plot(xc, yc, 'LineStyle','--','Color',[0.3 0.3 0.3],'LineWidth',0.3);
    end
    
    xlim([-5 5]); ylim([-5 5]);
    
    % Capture frame and write GIF
    frame = getframe(fig1); im = frame2im(frame); [imind,cm] = rgb2ind(im,256);
    if k==1
        imwrite(imind,cm,plot_gif,'gif','Loopcount',inf,'DelayTime',0.1);
    else
        imwrite(imind,cm,plot_gif,'gif','WriteMode','append','DelayTime',0.1);
    end
    
    % ---------- Scatter subplot ----------
    theta_scatter = repmat(theta,1,num_lines);
    rho_scatter = rho_vals;
    
    % Exact [m,q] from [theta,rho]
    m_vals = -cos(theta_scatter)./sin(theta_scatter);
    q_vals = rho_scatter ./ sin(theta_scatter);
    
    fig2 = figure(2); clf; 
    tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
    
    % Scatter: [m,q] subplot
    nexttile
    scatter(m_vals, q_vals, 80, 'filled')
    grid on; xlabel('m'); ylabel('q'); title('Slope-Intercept Form [m,q]');
    xlim([-100 0]); ylim([-40 40]);
    
    % Scatter: [theta,rho] subplot
    nexttile
    scatter(theta_scatter, rho_scatter, 80, 'filled')
    grid on; xlabel('\theta [rad]'); ylabel('\rho [m]'); title('Normal Form [\theta,\rho]');
    xlim([0 4]); ylim([-4 4]);
    
    % Capture frame and write GIF
    frame = getframe(fig2); im = frame2im(frame); [imind,cm] = rgb2ind(im,256);
    if k==1
        imwrite(imind,cm,scatter_gif,'gif','Loopcount',inf,'DelayTime',0.1);
    else
        imwrite(imind,cm,scatter_gif,'gif','WriteMode','append','DelayTime',0.1);
    end
end
