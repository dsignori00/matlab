function best_laps = fit_best_laps(v2v_data, log, opp_file)

    LOW_PASS_FREQ = 10; % [Hz]
    LAP_TIME_MIN = 100; % [s]
    LAP_TIME_MAX = 150; % [s]
    s = tf('s');
    lowpass_filt = 1 / (s/(2*pi*LOW_PASS_FREQ) + 1);
    derivative_filt = s / (s/(2*pi*LOW_PASS_FREQ) + 1);

    CURVATURE_RESAMPLE_PARAMS.rho_windowsidelen = 20;
    CURVATURE_RESAMPLE_PARAMS.rho_n_filters = 10;
    CURVATURE_RESAMPLE_PARAMS.s_windowsidelen = 20;
    CURVATURE_RESAMPLE_PARAMS.s_n_filters = 10;
    CURVATURE_RESAMPLE_PARAMS.rho_min_threshold = 5e-3;
    CURVATURE_RESAMPLE_PARAMS.N_new_points = 1000;

    SMOOTHING_TOL = 1.5; % [m];

    % Compute sampling time Ts from first ego lap
    Ts = mean(diff(v2v_data.lap_time(v2v_data.laps(:, 1)==1, 1)));

    % Interpolate ego vehicle data
    dataset_polimove = reinterp_ego_data(log, Ts);

    % Filename for caching results
    res_file_name = fullfile("mat", opp_file + "_best_laps.mat");

    if isfile(res_file_name)
        % Load cached results
        data = load(res_file_name);
        best_laps = data.best_laps;

    else
        % --- Process EGO vehicle (index 1)
        best_lap_polimove = extract_best_lap(dataset_polimove, 1, LAP_TIME_MIN, LAP_TIME_MAX);
        best_lap_polimove = filter_data(best_lap_polimove, lowpass_filt, derivative_filt, Ts);
        best_lap_polimove = fit_trajectory(best_lap_polimove, CURVATURE_RESAMPLE_PARAMS, SMOOTHING_TOL);

        best_laps(1) = best_lap_polimove;

        % --- Process each opponent
        for i = 2:v2v.max_opp + 1
            % Extract
            extracted = extract_best_lap(v2v_data, i-1, LAP_TIME_MIN, LAP_TIME_MAX);
            best_laps(i) = struct();

            % Copy fields
            for f = fieldnames(extracted)'
                best_laps(i).(f{1}) = extracted.(f{1});
            end

            % Filter
            filtered = filter_data(best_laps(i), lowpass_filt, derivative_filt, Ts);
            for f = fieldnames(filtered)'
                best_laps(i).(f{1}) = filtered.(f{1});
            end

            % Fit
            fitted = fit_trajectory(best_laps(i), CURVATURE_RESAMPLE_PARAMS, SMOOTHING_TOL);
            for f = fieldnames(fitted)'
                best_laps(i).(f{1}) = fitted.(f{1});
            end
        end

        % Save results
        if ~exist('../mat', 'dir')
            mkdir('../mat');
        end
        save(res_file_name, 'best_laps');
    end
end
