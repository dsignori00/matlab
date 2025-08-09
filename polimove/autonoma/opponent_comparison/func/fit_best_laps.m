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

    Ts = mean(diff(v2v_data.laptime_prog(v2v_data.laps(:, 1)==1, 1)));
    dataset_polimove = reinterp_ego_data(log, Ts);

    mat_dir = "mat";
    if ~exist(mat_dir, 'dir')
        mkdir(mat_dir);
    end

    total_vehicles = v2v_data.max_opp + 1;

    [~, name, ~] = fileparts(opp_file);
    parts = split(name, "_");
    file_prefix = parts{1};  
    
    for i = 1:total_vehicles
        if i == 1
            name = "ego";
        else
            name = "opp" + string(i - 1);
        end
    
        filename = fullfile(mat_dir, file_prefix + "_" + name + "_best_lap.mat");
    
        if ~isfile(filename)
            if i == 1
                lap = extract_best_lap(dataset_polimove, 1, LAP_TIME_MIN, LAP_TIME_MAX);
            else
                lap = extract_best_lap(v2v_data, i - 1, LAP_TIME_MIN, LAP_TIME_MAX);
            end
            
            if(~isnan(lap.x))
                lap = filter_data(lap, lowpass_filt, derivative_filt, Ts);
                lap = fit_trajectory(lap, CURVATURE_RESAMPLE_PARAMS, SMOOTHING_TOL);
            end 
            save(filename, 'lap');
        end
    end

    % Merge all laps into one structure
    fprintf("Merging all mats...")
    pattern = fullfile("mat", parts{1} + "_*_best_lap.mat");
    files = dir(pattern);
    best_laps = cell(numel(files),1);
    
    for i = 1:numel(files)
        filename = fullfile(files(i).folder, files(i).name);
        data = load(filename);
        best_laps{i} = data.lap;
        delete(filename);
    end
    save(fullfile(mat_dir, parts{1} + "_" + parts{4} + "_best_laps.mat"), 'best_laps');
    fprintf(" done. \n")
end

