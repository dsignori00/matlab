%% MMAE P_pos — figura 1
if ~isfield(tt, 'mmae_p_pos')
    warning('mmae_p_pos not available in log');
else
    n_filters = size(tt.mmae_p_pos, 3);
    cmap = lines(n_filters);

    figure(f); f = f + 1;
    tl = tiledlayout(n_filters, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, sprintf('MMAE P_{pos} per filter — %s', tt.name));

    for fi = 1:n_filters
        nexttile;
        data = squeeze(tt.mmae_p_pos(:, 1:min(opp_idx, tt.max_opp), fi)); % [N x n_opp]
        plot(tt.stamp, data, 'Color', cmap(fi,:), 'LineWidth', 1.2, ...
            'DisplayName', sprintf('F%d', fi));
        ylabel(sprintf('F%d', fi));
        grid on;
        xlim(x_lim);
        title(sprintf('Filter %d — P_{pos}', fi));
        legend('Location', 'best');
        if fi == n_filters
            xlabel('time [s]');
        end
    end
    axes(end+1) = gca; %#ok<AGROW>
end

%% MMAE P_vel — figura 2
if ~isfield(tt, 'mmae_p_vel')
    warning('mmae_p_vel not available in log');
else
    n_filters = size(tt.mmae_p_vel, 3);
    cmap = lines(n_filters);

    figure(f); f = f + 1;
    tl = tiledlayout(n_filters, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, sprintf('MMAE P_{vel} per filter — %s', tt.name));

    for fi = 1:n_filters
        nexttile;
        data = squeeze(tt.mmae_p_vel(:, 1:min(opp_idx, tt.max_opp), fi)); % [N x n_opp]
        plot(tt.stamp, data, 'Color', cmap(fi,:), 'LineWidth', 1.2, ...
            'DisplayName', sprintf('F%d', fi));
        ylabel(sprintf('F%d', fi));
        grid on;
        xlim(x_lim);
        title(sprintf('Filter %d — P_{vel}', fi));
        legend('Location', 'best');
        if fi == n_filters
            xlabel('time [s]');
        end
    end
    axes(end+1) = gca; %#ok<AGROW>
end