function tt = load_tt(log)
    if isfield(log, "perception__opponents")
        tt.stamp = log.perception__opponents.stamp__tot;
        % relative
        tt.x_rel = log.perception__opponents.opponents__x_rel;
        tt.y_rel = log.perception__opponents.opponents__y_rel;
        tt.rho_dot = log.perception__opponents.opponents__rho_dot;
        tt.yaw_rel = rad2deg(wrapToPi(log.perception__opponents.opponents__psi_rel));
        tt.x_rel(tt.x_rel==0)=nan;
        tt.y_rel(tt.y_rel==0)=nan;
        tt.rho_dot(tt.rho_dot==0)=nan;
        tt.yaw_rel(tt.yaw_rel==0)=nan;
        % map
        tt.x_map = log.perception__opponents.opponents__x_geom;
        tt.y_map = log.perception__opponents.opponents__y_geom;
        tt.vx = log.perception__opponents.opponents__vx;
        tt.yaw_map = rad2deg(wrapToPi(log.perception__opponents.opponents__psi));
        tt.ax = log.perception__opponents.opponents__ax;
        %tt.covariance = valid_covariance(log.perception__opponents.opponents__ekf_p);
        tt.count = log.perception__opponents.count;
        tt.max_opp = max(tt.count);
        tt.x_map(tt.x_map==0)=nan;
        tt.y_map(tt.y_map==0)=nan;
        tt.vx(tt.vx==0)=nan;
        tt.yaw_map(tt.yaw_map==0)=nan;
        tt.ax(tt.ax==0)=nan;
        if isfield(log.perception__opponents,"opponents__yaw_rate")
            tt.yaw_rate = rad2deg(log.perception__opponents.opponents__yaw_rate);
            tt.yaw_rate(tt.yaw_rate==0)=nan;
        elseif isfield(log.perception__opponents,"opponents__psi_dot")
            tt.yaw_rate = rad2deg(log.perception__opponents.opponents__psi_dot);
            tt.yaw_rate(tt.yaw_rate==0)=nan;
        end
        if isfield(log.perception__opponents,"opponents__ax_dot")
            tt.ax_dot = log.perception__opponents.opponents__ax_dot;
            tt.ax_dot(tt.ax_dot==0)=nan;
        end
        if isfield(log.perception__opponents,"opponents__ff_flag")
            tt.ff_flag = log.perception__opponents.opponents__ff_flag;
        end
        if isfield(log.perception__opponents,"opponents__probabilities")
            tt.imm.probabilities = log.perception__opponents.opponents__probabilities;
            tt.imm.likelihoods = log.perception__opponents.opponents__likelihoods;
            tt.imm.residuals = log.perception__opponents.opponents__residuals;
        else
            tt.imm.probabilities = nan(size(tt.stamp));
            tt.imm.likelihoods = nan(size(tt.stamp));
            tt.imm.residuals = nan(size(tt.stamp));
        end
        % jerk stimato dal filtro (se il modello ha jerk come stato/output
        % loggato, es. modello a jerk costante). Prova i nomi di campo piu'
        % plausibili in ordine; nessun errore se non presenti.
        jerk_field_candidates = {"opponents__jerk", "opponents__jx", ...
            "opponents__ax_dot", "opponents__jerk_x"};
        for kk = 1:numel(jerk_field_candidates)
            fj = jerk_field_candidates{kk};
            if isfield(log.perception__opponents, fj)
                tt.jerk = log.perception__opponents.(fj);
                tt.jerk(tt.jerk==0) = nan;
                break;
            end
        end
        % associated measures
        if isfield(log.perception__opponents,"opponents__meas_count")
            tt.measures.count = log.perception__opponents.opponents__meas_count;
            tt.measures.source = log.perception__opponents.opponents__meas_source_type;
            tt.measures.stamp = log.perception__opponents.opponents__meas_stamp;
            tt.measures.x_map = log.perception__opponents.opponents__meas_x_map;
            tt.measures.y_map = log.perception__opponents.opponents__meas_y_map;
            tt.measures.stamp(tt.measures.stamp==0)=nan;
            tt.measures.x_map(tt.measures.x_map==0)=nan;
            tt.measures.y_map(tt.measures.y_map==0)=nan;
            tt.measures.stamp = tt.measures.stamp - log.time_offset_nsec*1e-9;
        end
        % closest trajectory index
        if isfield(log.perception__opponents, "opponents__closest_idx")
            tt.closest_idx = log.perception__opponents.opponents__closest_idx;
            tt.closest_idx(tt.closest_idx == 0) = nan;
        end
        % Q feedforward debug
        if isfield(log.perception__opponents, "opponents__ekf_q")
            raw_q = log.perception__opponents.opponents__ekf_q; % [N x n_opp x 36]
            tt.Q_aa = squeeze(raw_q(:, :, 36));
            tt.Q_aa(tt.Q_aa == 0) = nan;
        end
        if isfield(log.perception__opponents, "opponents__q_lambda")
            tt.q_lambda = log.perception__opponents.opponents__q_lambda;
            tt.q_lambda(tt.q_lambda == 0) = nan;
        end
        % Kalman gain reale (loggato) su velocita' e accelerazione, canale rho_dot
        if isfield(log.perception__opponents, "opponents__k_v")
            tt.K_v = log.perception__opponents.opponents__k_v;
            tt.K_v(tt.K_v == 0) = nan;
        end
        if isfield(log.perception__opponents, "opponents__k_a")
            tt.K_a = log.perception__opponents.opponents__k_a;
            tt.K_a(tt.K_a == 0) = nan;
        end
        % MMAE (campi allineati al log: weights, mahalanobis, log_det_s, det_s, det_p, acc_gain)
        if isfield(log.perception__opponents, "opponents__mmae_weights")
            tt.mmae_weights = mask_mmae(log.perception__opponents.opponents__mmae_weights);
        end
        if isfield(log.perception__opponents, "opponents__mmae_mahalanobis")
            tt.mmae_mahalanobis = mask_mmae(log.perception__opponents.opponents__mmae_mahalanobis);
        end
        if isfield(log.perception__opponents, "opponents__mmae_log_det_s")
            tt.mmae_logdet_s = mask_mmae(log.perception__opponents.opponents__mmae_log_det_s);
        end
        if isfield(log.perception__opponents, "opponents__mmae_det_s")
            tt.mmae_det_s = mask_mmae(log.perception__opponents.opponents__mmae_det_s);
        end
        if isfield(log.perception__opponents, "opponents__mmae_det_p")
            tt.mmae_det_p = mask_mmae(log.perception__opponents.opponents__mmae_det_p);
        end
        if isfield(log.perception__opponents, "opponents__mmae_acc_gain")
            tt.mmae_gain_acc = mask_mmae(log.perception__opponents.opponents__mmae_acc_gain);
        end
        % varianti "common" (stessa S/Mahalanobis con normalizzazione comune)
        if isfield(log.perception__opponents, "opponents__mmae_mahalanobis_common")
            tt.mmae_mahalanobis_common = mask_mmae(log.perception__opponents.opponents__mmae_mahalanobis_common);
        end
        if isfield(log.perception__opponents, "opponents__mmae_log_det_s_common")
            tt.mmae_logdet_s_common = mask_mmae(log.perception__opponents.opponents__mmae_log_det_s_common);
        end
        % R adattata, INNOVAZIONE per ogni sensore (R in frame RELATIVO)
        % shape: [N x n_opp x 4] (2x2 row-major). Niente flag *_meas disponibili:
        % il mascheramento si basa solo sugli zeri/placeholder (vedi mask_field).
        sens_list = {'lidar','pp','radar','camera'};
        for k = 1:numel(sens_list)
            s  = sens_list{k};
            fr  = char("opponents__r_adapt_"        + s);
            fr2 = char("opponents__r_adapt_" + s + "_2sigma");
            fi  = char("opponents__innov_"          + s);
            fiw = char("opponents__innov_white_"    + s);
            if isfield(log.perception__opponents, fr)
                tt.R.(s) = mask_field(log.perception__opponents.(fr));
            end
            if isfield(log.perception__opponents, fr2)
                tt.R2.(s) = mask_field(log.perception__opponents.(fr2));
            end
            if isfield(log.perception__opponents, fi)
                tt.innov.(s) = mask_field(log.perception__opponents.(fi));
            end
            if isfield(log.perception__opponents, fiw)
                tt.innov_white.(s) = mask_field(log.perception__opponents.(fiw));
            end
        end

        % R adattata per rho_dot del radar (scalare, 1D)
        if isfield(log.perception__opponents, "opponents__r_adapt_rhodot_radar")
            tt.R_rhodot = mask_field(log.perception__opponents.opponents__r_adapt_rhodot_radar);
        end

        % INNOVAZIONE vera per sensore (nomi di campo come loggati in questo
        % log: opponents__innovation_<sensore>, diversi dalla convenzione
        % opponents__innov_<sensore> usata sopra per R adattiva/innov_white -
        % percio' un blocco a parte, con la mappa nome-sensore corretta.
        % Non sovrascrive tt.innov.(s) se gia' popolato dal loop precedente.
        innov_field_map = { ...
            'lidar',  'opponents__innovation_lid_clust'; ...
            'pp',     'opponents__innovation_lid_pp'; ...
            'radar',  'opponents__innovation_rad_clust'; ...
            'camera', 'opponents__innovation_cam_yolo' ...
        };
        for k = 1:size(innov_field_map, 1)
            s_key = innov_field_map{k,1};
            f_name = innov_field_map{k,2};
            if isfield(log.perception__opponents, f_name) && ...
               ~(isfield(tt, 'innov') && isfield(tt.innov, s_key))
                tt.innov.(s_key) = mask_field(log.perception__opponents.(f_name));
            end
        end
    else
        error('No target tracking data found in the log.');
    end
end

% ===================== helper locale =====================
function d = mask_field(d)
    d(d == 0)    = nan;
    d(d == -1)   = nan;   % placeholder camera non valido
    d(d <= -9999) = nan;  % sentinella "no data" (~-10000), soglia robusta
end

function d = mask_mmae(d)
    d(d == 0)    = nan;
    d(d <= -9999) = nan;  % sentinella "no data" (niente -1: logdet puo' essere negativo)
end