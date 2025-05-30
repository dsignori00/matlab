function plot_data_delay_lat(data, TURN_NAME)

    idx_start_vec = [];
    idx_end_vec = [];

    [idx_turn_start, idx_turn_end] = get_lat_delay_idx(TURN_NAME);

    in_turn_vec = data.track_idx > idx_turn_start & data.track_idx < idx_turn_end;

    for i=10:length(data.time)-8
        if sum(in_turn_vec(i-9:i-1)) == 0 &&  sum(in_turn_vec(i:i+8)) == 9
            idx_start_vec(end+1) = i; %#ok<AGROW> 
        end

        if sum(in_turn_vec(i-9:i-1)) == 9 &&  sum(in_turn_vec(i:i+8)) == 0
            idx_end_vec(end+1) = i; %#ok<AGROW> 
        end

    end

    idx_end_vec(end+1) = length(data.time);

    new_idx_end_vec = ones(size(idx_start_vec));

    for i=1:length(idx_start_vec)
        new_idx_end_vec(i) = idx_end_vec(find(idx_end_vec > idx_start_vec(i), 1, 'first'));
    end

    for i=1:length(idx_start_vec)
        figure
        

        sp(1) = subplot(8, 3, [1:2 4:5]);
        hold on; grid on;
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), 2.2*data.vx_hat(idx_start_vec(i):new_idx_end_vec(i)), 'Color', 'b', 'DisplayName', 'vx');
        legend show;

        if any(isnan(data.beta_dot_time_prev))
            data.beta_dot_time_prev(idx_start_vec(i):new_idx_end_vec(i)) = zeros(size(data.time(idx_start_vec(i):new_idx_end_vec(i))));
        end
        
        sp(2) = subplot(8, 3, 3);
        hold on; grid on;
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), data.beta_dot_time_prev(idx_start_vec(i):new_idx_end_vec(i)), 'Color', 'b', 'DisplayName', '$\dot{\beta}_{tp}$');
        legend show;

        sp(3) = subplot(8, 3, 6);
        hold on; grid on;
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), data.muy_gain_ref(idx_start_vec(i):new_idx_end_vec(i)), 'Color', 'b', 'DisplayName', '$\mu_y$');
        legend show;

        sp(4) = subplot(8, 3, 7:12);
        hold on; grid on;
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), data.e_lat(idx_start_vec(i):new_idx_end_vec(i)), 'Color', 'b', 'DisplayName', 'lateral error');
        legend show;

        sp(5) = subplot(8, 3, 13:18);
        hold on; grid on;
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), data.yaw_rate_ref(idx_start_vec(i):new_idx_end_vec(i)), 'Color', 'r', 'DisplayName', 'yaw rate ref');
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), data.omega_z_hat(idx_start_vec(i):new_idx_end_vec(i)), 'Color', 'b', 'DisplayName', 'yaw rate fbk');
        legend show;

        sp(6) = subplot(8, 3, 19:24);
        hold on; grid on;
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), rad2deg(data.steer_angle_command_tot(idx_start_vec(i):new_idx_end_vec(i))), 'Color', 'r', 'DisplayName', 'steer ref');
        plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), rad2deg(data.delta_sw(idx_start_vec(i):new_idx_end_vec(i)))/(19.5*3/4), 'Color', 'b', 'DisplayName', 'steer fbk');
        legend show;

        sgtitle(TURN_NAME)

%         sp(7) = figure;
%         plot(data.time(idx_start_vec(i):new_idx_end_vec(i)), data.gear(idx_start_vec(i):new_idx_end_vec(i)), 'Color', 'b', 'DisplayName', 'gear');
%         legend show;

        linkaxes(sp, 'x');

    end

end

