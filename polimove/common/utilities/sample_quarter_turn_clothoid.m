function [points, rho_vec] = sample_quarter_turn_clothoid(RHO_MAX, DS_CONST, DS)

    N_steps_tot = round(pi/2/RHO_MAX/DS);
    N_steps_const = round(DS_CONST/DS);
    N_steps_ramp = N_steps_tot - N_steps_const;

    new_rho_max = pi / 2 / N_steps_tot / DS;
    fresnel_input_scaling = sqrt(1/(2*N_steps_tot*N_steps_ramp));
    fresnel_output_scaling = DS * sqrt(2*N_steps_tot*N_steps_ramp);

    dt_ramp = ((0:(N_steps_ramp)).*fresnel_input_scaling).';

    [x_vec_ramp, y_vec_ramp] = fresnel_numeric(dt_ramp);
    
    x_vec_ramp = x_vec_ramp .* fresnel_output_scaling;
    y_vec_ramp = y_vec_ramp .* fresnel_output_scaling;

    x_vec_ramp_end = x_vec_ramp(end);
    y_vec_ramp_end = y_vec_ramp(end);
    psi_ramp_end = pi * (N_steps_ramp / 4 / N_steps_tot);
    psi_ramp_end_3pi2 = pi/4 * (6 + N_steps_ramp / N_steps_tot);

    x_center = x_vec_ramp_end - (1/new_rho_max) * cos(psi_ramp_end_3pi2);
    y_center = y_vec_ramp_end - (1/new_rho_max) * sin(psi_ramp_end_3pi2);

    psi_const_vec = psi_ramp_end + (1:(N_steps_const-1)).' .* (pi/2/N_steps_tot);

    x_vec_const = x_center + (1/new_rho_max) .* cos(3/2*pi+psi_const_vec);
    y_vec_const = y_center + (1/new_rho_max) .* sin(3/2*pi+psi_const_vec);

    x_vec_ramp_2 = x_center - (y_vec_ramp - y_center);
    y_vec_ramp_2 = y_center - (x_vec_ramp - x_center);

    x_vec = [x_vec_ramp; x_vec_const; flip(x_vec_ramp_2)];
    y_vec = [y_vec_ramp; y_vec_const; flip(y_vec_ramp_2)];

    x_vec = x_vec - x_vec(1);
    y_vec = y_vec - y_vec(end);

    points = [x_vec y_vec];
    rho_vec = [linspace(0, new_rho_max, N_steps_ramp+1).'; 
               new_rho_max.*ones(N_steps_const-1, 1);
               linspace(new_rho_max, 0, N_steps_ramp+1).'];

end

