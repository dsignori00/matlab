function plot_data_low_level_ctrl_P(data)

    kt = 1;

    figure, set(gcf, 'Color', 'White')   
    spt(kt)=subplot(4,1,1);
    kt=kt+1;
    hold on
    ylabel('delta [deg]')
    plot(data.time,rad2deg(data.steer_angle_command_tot), 'Color', 'r', 'DisplayName', 'steer cmd');
    plot(data.time,rad2deg(data.delta_sw/(19.5*3/4)), 'Color', 'b', 'DisplayName', 'steer');
    legend show;

    spt(kt)=subplot(4,1,2);
    kt=kt+1;
    hold on
    ylabel('throttle [0-1]')
    plot(data.time,data.throttle_pedal_ctrl, 'Color', 'r', 'DisplayName', 'throttle cmd');
    plot(data.time,data.throttle, 'Color', 'b', 'DisplayName', 'throttle fbk');
    legend show;

    spt(kt)=subplot(4,1,3);
    kt=kt+1;
    hold on
    ylabel('brake [kPa]')
    plot(data.time,data.p_brake_ctrl/1000, 'Color', 'r', 'DisplayName', 'brake cmd');
    plot(data.time,data.p_brake_front, '--', 'Color', 'b', 'DisplayName', 'brake front');
    plot(data.time,data.p_brake_rear, '--', 'Color', 'g', 'DisplayName', 'brake rear');
    legend show;

    p_brake_bias = data.p_brake_front ./ (data.p_brake_front + data.p_brake_rear);

    spt(kt)=subplot(4,1,4);
    hold on
    ylabel('brake bias [-]')
    plot(data.time,p_brake_bias, '-', 'Color', 'b', 'DisplayName', 'brake bias');
    legend show;

    linkaxes(spt,'x');

end

