% Error Analysis 
figure("Name","Tracking Error")

% button
c = c + 1;
b(c) = uicontrol('Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshErrorSummaryButtonPushed);

function refreshErrorSummaryButtonPushed(~,~)

    % --- fetch from base ---
    tt       = evalin('base','tt');
    ax_ref   = evalin('base','axes');
    err_thr  = evalin('base','err_thr');
    errors   = evalin('base','errors');

    % --- compute stats for specified time window ---

    % time window from reference axis
    t_lim = xlim(ax_ref(1));
    [t1, tend] = timeWindowIdx(tt.stamp, t_lim);

    time = false(size(tt.stamp));
    time(t1:tend) = true;

    ass = hypot(errors.x_map_err, errors.y_map_err) < err_thr;
    errors.idx = ass & time;

    stats = {'x_rel','y_rel','vx'};
    for l = stats
        err = errors.([l{1} '_err']);
        errors.([l{1} '_std'])  = std(err(errors.idx));
        errors.([l{1} '_mean']) = mean(err(errors.idx));
    end

    [errors.x_ellipse, errors.y_ellipse] = calculate_ellipse( ...
        errors.x_rel_std, errors.y_rel_std, ...
        errors.x_rel_mean, errors.y_rel_mean);


    % --- Positional errors (ellipse) ---
    ax_pos = subplot(3,2,[1 3 5]);
    cla reset; hold(ax_pos,'on'); grid(ax_pos,'on'); axis(ax_pos,'equal')

    plot(ax_pos, errors.y_ellipse, errors.x_ellipse, ...
        'Color', tt.col, ...
        'LineWidth', 2, ...
        'DisplayName', tt.name)

    scatter(ax_pos, errors.y_rel_mean, errors.x_rel_mean, ...
        'o', ...
        'MarkerFaceColor', tt.col, ...
        'MarkerEdgeColor', tt.col, ...
        'HandleVisibility','off')

    str = sprintf('σ_x = %.2f m\nσ_y = %.2f m', ...
        errors.x_rel_std, errors.y_rel_std);

    text(ax_pos, errors.y_rel_mean, errors.x_rel_mean, str, ...
        'Interpreter','none', ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','right', ...
        'FontSize',15, ...
        'FontWeight','bold', ...
        'Color','k', ...
        'BackgroundColor',[1 1 1 0.75], ...
        'EdgeColor', tt.col, ...
        'Margin',3, ...
        'HandleVisibility','off');

    xline(ax_pos,0,'--','LineWidth',0.3,'HandleVisibility','off')
    yline(ax_pos,0,'--','LineWidth',0.3,'HandleVisibility','off')
    title(ax_pos,'Positional Errors')
    xlabel(ax_pos,'y rel [m]')
    ylabel(ax_pos,'x rel [m]')
    legend(ax_pos,'show')

    % --- Error distribution ---
    ax_hist = gobjects(1,numel(stats)); k = 0;
    for l = stats
        k = k + 1;
        ax_hist(k) = subplot(3,2,k*2);
        cla reset; hold(ax_hist(k),'on'); grid(ax_hist(k),'on')
        histogram(ax_hist(k), errors.([l{1} '_err'])(errors.idx), 30, ...
                'Normalization','pdf', ...
                'FaceColor', tt.col, ...
                'DisplayName', tt.name);

        legend(ax_hist(k), ...
            'Interpreter','none', ...
            'Box','on');

        ylbl = sprintf(l{1});
        ylbl = strrep(ylbl, '_', '\_');
        ylabel(ax_hist(k), ylbl)
    end
    title(ax_hist(1),'Error Distribution - PDF')

end
