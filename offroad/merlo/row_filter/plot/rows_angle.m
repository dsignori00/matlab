figure("Name","Row Angle")
tiledlayout(2,1);

%% cog frame
angles     = [];
meas_stamp = [];
nIters = size(bag1.measures.num_fitted_lines,1);
for i = 1:nIters
    nRows_i = bag1.measures.num_fitted_lines(i);
    coeff_i = bag1.measures.coeff(i, 1:nRows_i, :);
        
    if nRows_i == 0
        continue
    end
    % Compute angles for this iteration
    angles_i = 2 * atan2(coeff_i(1,:,5), coeff_i(1,:,4));
    angles_i = mod(angles_i + pi/2, pi) - pi/2;
    angles_i = angles_i(:);   

    % Accumulate
    angles     = [angles; angles_i];
    meas_stamp = [meas_stamp; repmat(bag1.measures.stamp(i), nRows_i, 1)];
end

bag1.rows_angle.measures   = angles;
bag1.rows_angle.meas_stamp = meas_stamp;
bag1.rows_angle.stamp = bag1.info.stamp;
bag1.rows_angle.angle_cog = bag1.info.rows_angle_cog;
bag1.rows_angle.angle_map = bag1.info.rows_angle_map;

ax(f) = nexttile; f=f+1; hold on; grid on;
scatter(bag1.rows_angle.meas_stamp, bag1.rows_angle.measures * RAD2DEG, 'o', ...
        'MarkerEdgeColor', colors.green{1}, 'MarkerFaceColor', colors.green{1}, ...
        'DisplayName', "measures");
plot(bag1.measures.stamp,bag1.rows_angle.angle_cog, "Color",colors.matlab{1},"DisplayName","angle");
ylabel("cog");
title("Rows angle [deg]")
legend show

%% map frame
ax(f) = nexttile; f=f+1; hold on; grid on;
plot(bag1.measures.stamp,bag1.rows_angle.angle_map,"Color",colors.matlab{1},"DisplayName","angle");
ylabel("map");
legend show