%%
% clearvars
close all

tic

%%
load('C:\Users\Matteo\Desktop\2025-04-17_17-56_normal.mat')

mpc_data = log.control__mpc__command;

start_idx = 10000;
end_idx = 10000 + 100;
Ts = 0.03;
N = 60;
t_horizon         = 0 : Ts : Ts*N; % todo rename

% Graphic options
t_horizon_ticks   = 0 : 0.5 : 1.5; % todo rename


%% init plot
% 
%  XY      s/k   eps
%  XY      ay    GG
% n  mu    r       ax
% v beta   r_ref ax_ref

% TODO labels

fig             = figure('numbertitle', 'off');
fig.Name        = "MPC debugger";
tcl             = tiledlayout(4,4);
tcl.TileSpacing = 'compact';
tcl.Padding     = 'compact';

% Title
title(tcl, 'MPC debugger');

% XY map
ax_map = nexttile([2 2]); hold on, grid on, box on; axis equal;

% Cost function
axis_cost = nexttile(3); hold on, grid on, box on;
ylabel('Cost [-]');

% Slack variable
axis_slack = nexttile(4); hold on, grid on, box on;
plot_slack_pred = stairs(axis_slack, t_horizon, zeros(size(t_horizon)));
set(axis_slack, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_slack, 'XLimMode', 'manual');
set(axis_slack, 'XTick', t_horizon_ticks);
set(axis_slack, 'XTickMode', 'manual');
ylabel('[g]');

% Lateral acceleration
axis_ay = nexttile(7); hold on, grid on, box on;
plot_ay = plot(axis_ay, t_horizon, zeros(size(t_horizon)));
plot_ay_pred = stairs(axis_ay, t_horizon, zeros(size(t_horizon)));
set(axis_ay, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_ay, 'XLimMode', 'manual');
set(axis_ay, 'XTick', t_horizon_ticks);
set(axis_ay, 'XTickMode', 'manual');
ylabel('[g]');

% GG plot
axis_gg = nexttile(8); hold on, grid on, box on;
ylabel('[g]');

% Lateral error
axis_n = nexttile(9); hold on, grid on, box on;
plot_n = plot(axis_n, t_horizon, zeros(size(t_horizon)));
plot_n_pred = stairs(axis_n, t_horizon, zeros(size(t_horizon)));
set(axis_n, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_n, 'XLimMode', 'manual');
set(axis_n, 'XTick', t_horizon_ticks);
set(axis_n, 'XTickMode', 'manual');
ylabel('[m]');

% Heading error
axis_mu = nexttile(10); hold on, grid on, box on;
plot_mu = plot(axis_mu, t_horizon, zeros(size(t_horizon)));
plot_mu_pred = stairs(axis_mu, t_horizon, zeros(size(t_horizon)));
set(axis_mu, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_mu, 'XLimMode', 'manual');
set(axis_mu, 'XTick', t_horizon_ticks);
set(axis_mu, 'XTickMode', 'manual');
ylabel('[deg]');

% Yaw rate
axis_r = nexttile(11); hold on, grid on, box on;
plot_r = plot(axis_r, t_horizon, zeros(size(t_horizon)));
plot_r_pred = stairs(axis_r, t_horizon, zeros(size(t_horizon)));
set(axis_r, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_r, 'XLimMode', 'manual');
set(axis_r, 'XTick', t_horizon_ticks);
set(axis_r, 'XTickMode', 'manual');
ylabel('[deg]');

% Longitudinal acceleration
axis_ax = nexttile(12); hold on, grid on, box on;
plot_ax = plot(axis_ax, t_horizon, zeros(size(t_horizon)));
plot_ax_pred = stairs(axis_ax, t_horizon, zeros(size(t_horizon)));
set(axis_ax, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_ax, 'XLimMode', 'manual');
set(axis_ax, 'XTick', t_horizon_ticks);
set(axis_ax, 'XTickMode', 'manual');
ylabel('[g]');

% Speed
axis_speed = nexttile(13); hold on, grid on, box on;
plot_speed = plot(axis_speed, t_horizon, zeros(size(t_horizon)));
plot_speed_pred = stairs(axis_speed, t_horizon, zeros(size(t_horizon)));
set(axis_speed, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_speed, 'XLimMode', 'manual');
set(axis_speed, 'XTick', t_horizon_ticks);
set(axis_speed, 'XTickMode', 'manual');
ylabel('[m/s]');
xlabel('Time [s]')

% Sideslip angle
axis_beta = nexttile(14); hold on, grid on, box on;
plot_beta = plot(axis_beta, t_horizon, zeros(size(t_horizon)));
plot_beta_pred = stairs(axis_beta, t_horizon, zeros(size(t_horizon)));
set(axis_beta, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_beta, 'XLimMode', 'manual');
set(axis_beta, 'XTick', t_horizon_ticks);
set(axis_beta, 'XTickMode', 'manual');
ylabel('[deg]');
xlabel('Time [s]')

% Reference yaw rate
axis_r_ref = nexttile(15); hold on, grid on, box on;
plot_r_ref = plot(axis_r_ref, t_horizon, zeros(size(t_horizon)));
plot_r_ref_pred = stairs(axis_r_ref, t_horizon, zeros(size(t_horizon)));
set(axis_r_ref, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_r_ref, 'XLimMode', 'manual');
set(axis_r_ref, 'XTick', t_horizon_ticks);
set(axis_r_ref, 'XTickMode', 'manual');
ylabel('[deg]');
xlabel('Time [s]')

% Reference longitudinal acceleration
axis_ax_ref = nexttile(16); hold on, grid on, box on;
plot_ax_ref = plot(axis_ax_ref, t_horizon, zeros(size(t_horizon)));
plot_ax_ref_pred = stairs(axis_ax_ref, t_horizon, zeros(size(t_horizon)));
set(axis_ax_ref, 'XLim', [t_horizon(1) t_horizon(end)]);
set(axis_ax_ref, 'XLimMode', 'manual');
set(axis_ax_ref, 'XTick', t_horizon_ticks);
set(axis_ax_ref, 'XTickMode', 'manual');
ylabel('[g]');
xlabel('Time [s]')


%% init frame vector

frame = getframe(fig);

n_frames = end_idx - start_idx + 1;

frames = repmat(frame, 1, n_frames);


%%

for idx_iter = start_idx : end_idx

    % Compute indexes and time vector for ground truth signals
    idx_iter_end = idx_iter;
    while mpc_data.bag_stamp(idx_iter_end) < mpc_data.bag_stamp(idx_iter) + N*Ts && idx_iter_end < length(mpc_data.bag_stamp)
        idx_iter_end = idx_iter_end + 1;
    end    
    idxs_meas = idx_iter:idx_iter_end;
    t_horizon_meas = mpc_data.bag_stamp(idxs_meas) - mpc_data.bag_stamp(idx_iter);

    % XY map

    % Cost function

    % Slack variable
    set(plot_slack_pred, ...
        'YData', 1/9.81 * [mpc_data.horizon_slack_ay_error(idx_iter,:)]);

    % Lateral acceleration
    set(plot_ay, ...
        'XData', t_horizon_meas, ...
        'YData', 1/9.81 * mpc_data.yaw_rate(idxs_meas) .* mpc_data.long_speed(idxs_meas));
    set(plot_ay_pred, ...
        'YData', 1/9.81 * [mpc_data.yaw_rate(idx_iter) .* mpc_data.long_speed(idx_iter) mpc_data.horizon_yaw_rate(idx_iter,:) .* mpc_data.horizon_long_speed(idx_iter,:)]);

    % GG plot


    % Lateral error
    set(plot_n, ...
        'XData', t_horizon_meas, ...
        'YData', mpc_data.lateral_error(idxs_meas));
    set(plot_n_pred, ...
        'YData', [mpc_data.lateral_error(idx_iter) mpc_data.horizon_lateral_error(idx_iter,:)]);

    % Heading error
    set(plot_mu, ...
        'XData', t_horizon_meas, ...
        'YData', 180/pi * mpc_data.heading_error(idxs_meas));
    set(plot_mu_pred, ...
        'YData', 180/pi * [mpc_data.heading_error(idx_iter) mpc_data.horizon_heading_error(idx_iter,:)]);

    % Yaw rate
    set(plot_r, ...
        'XData', t_horizon_meas, ...
        'YData', 180/pi * mpc_data.yaw_rate(idxs_meas));
    set(plot_r_pred, ...
        'YData', 180/pi * [mpc_data.yaw_rate(idx_iter) mpc_data.horizon_yaw_rate(idx_iter,:)]);

    % Longitudinal acceleration
    set(plot_ax, ...
        'XData', t_horizon_meas, ...
        'YData', 1/9.81 * mpc_data.long_acc(idxs_meas));
    set(plot_ax_pred, ...
        'YData', 1/9.81 * [mpc_data.long_acc(idx_iter) mpc_data.horizon_long_acc(idx_iter,:)]);

    % Speed
    set(plot_speed, ...
        'XData', t_horizon_meas, ...
        'YData', 3.6 * mpc_data.long_speed(idxs_meas));
    set(plot_speed_pred, ...
        'YData', 3.6 * [mpc_data.long_speed(idx_iter) mpc_data.horizon_long_speed(idx_iter,:)]);

    % Sideslip angle
    set(plot_beta, ...
        'XData', t_horizon_meas, ...
        'YData', 180/pi * mpc_data.sideslip_angle(idxs_meas));
    set(plot_beta_pred, ...
        'YData', 180/pi * [mpc_data.sideslip_angle(idx_iter) mpc_data.horizon_sideslip_angle(idx_iter,:)]);

    % Reference yaw rate
    set(plot_r_ref, ...
        'XData', t_horizon_meas, ...
        'YData', 180/pi * mpc_data.yaw_rate_ref(idxs_meas));
    set(plot_r_ref_pred, ...
        'YData', 180/pi * [mpc_data.yaw_rate_ref(idx_iter) mpc_data.horizon_yaw_rate_ref(idx_iter,:)]);

    % Reference longitudinal acceleration
    set(plot_ax_ref, ...
        'XData', t_horizon_meas, ...
        'YData', 1/9.81 * mpc_data.long_acc_ref(idxs_meas));
    set(plot_ax_ref_pred, ...
        'YData', 1/9.81 * [mpc_data.long_acc_ref(idx_iter) mpc_data.horizon_long_acc_ref(idx_iter,:)]);

    % Update figure
    drawnow

    % Save frame
    frames(idx_iter - start_idx + 1) = getframe(fig);

end


%% Save video

toc

% VideoWriter settings
v = VideoWriter("out.mp4", "MPEG-4");
v.FrameRate = 1/Ts;

% Write video from saved frames
open(v)
writeVideo(v,frames)
close(v)

