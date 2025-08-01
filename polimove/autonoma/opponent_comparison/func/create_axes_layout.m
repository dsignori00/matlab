function ax = create_axes_layout(fig, n_axes)
    ax_left = 0.14 + 0.05;
    ax_height = (0.8 - (n_axes - 1) * 0.05) / n_axes;
    ax = gobjects(n_axes, 1);

    for i = 1:n_axes
        bottom = 0.1 + (n_axes - i) * (ax_height + 0.05);
        ax(i) = axes('Parent', fig, ...
            'Position', [ax_left, bottom, 1 - ax_left - 0.05, ax_height]);
    end
end
