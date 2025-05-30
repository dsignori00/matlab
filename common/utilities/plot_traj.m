function plot_traj(database, data)

    figure
    hold on; grid on;
    plot(database(11).X, database(11).Y, "Color", 'r', 'LineWidth', 1.5);
    plot(database(23).X, database(23).Y, "Color", 'r', 'LineWidth', 1.5);
    plot(database(24).X, database(24).Y, "Color", 'r', 'LineWidth', 1.5);

    scatter(data.x_hat, data.y_hat, 100, data.time, 'filled');
    axis equal;

end

