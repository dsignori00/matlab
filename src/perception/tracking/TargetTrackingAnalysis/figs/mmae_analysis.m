%% MMAE ANALYSIS
% Analysis of the MMAE approach on the main log (tt), opponent opp_idx.
% Figure 1: weight evolution
% Figure 2: Mahalanobis (subplot 1) + logdet S (subplot 2) for the 4 Q values
% Figure 3: common Mahalanobis + common logdet S (only if *_common fields exist)
% Figure 4: acceleration gains (single plot, 4 filters)
% + Filter separability table (spread percent gains/residuals/logdetS) and bar chart
%
% All axes are explicitly linked on the x-axis at the end of the script.
%
% Requires fields loaded by load_tt:
%   tt.mmae_weights      -> [N x n_opp x 4]
%   tt.mmae_mahalanobis  -> [N x n_opp x 4]   (raw: opponents__mmae_mahalanobis)
%   tt.mmae_logdet_s     -> [N x n_opp x 4]   (raw: opponents__mmae_log_det_s)
%   tt.mmae_gain_acc     -> [N x n_opp x 4]   (raw: opponents__mmae_acc_gain)

n_models  = 4;
Q_values  = [5 15 45 135];        % process noise Q associated with each filter, in order
mdl_names = arrayfun(@(k) sprintf('Q = %d', Q_values(k)), 1:n_models, 'uni', false);
mdl_cols  = lines(n_models);
t = tt.stamp;

% candidate field names (adjust here if load_tt uses different names)
maha_cand = {'mmae_mahalanobis','mmae_maha'};

% helper: extracts the [N x 4] slice for the chosen opponent from a [N x n_opp x 4] field
get_slice = @(F) squeeze(F(:, opp_idx, :));
% helper: first existing field among candidates
pick_field = @(cands) cands(find(cellfun(@(c) isfield(tt,c), cands), 1));

% handles of MMAE axes (unique) to be linked at the end
mmae_axes = gobjects(0);

%% ===================== FIGURE 1: weights =====================
f = f + 1; figure(f); clf;
set(gcf, 'Name', sprintf('MMAE weights (opp %d)', opp_idx));
ax_w = gca; hold on; grid on;
if isfield(tt, 'mmae_weights')
    W = get_slice(tt.mmae_weights); % [N x 4]
    for k = 1:n_models
        plot(t, W(:,k), 'Color', mdl_cols(k,:), 'LineWidth', 1.2, ...
            'DisplayName', mdl_names{k});
    end
    ylabel('weight [-]', 'Interpreter', 'none');
    ylim([0 1]);
    legend('show', 'Location', 'best', 'Interpreter', 'none');
else
    title('mmae_weights not available', 'FontWeight', 'bold', 'Interpreter', 'none');
end
title('MMAE - Weight Evolution', 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('t [s]', 'Interpreter', 'none');
axes(end+1) = ax_w; %#ok<SAGROW>
mmae_axes(end+1) = ax_w;

%% ===================== FIGURE 2: Mahalanobis + logdet S (4 Q) =====================
f = f + 1; figure(f); clf;
set(gcf, 'Name', sprintf('MMAE mahalanobis & logdet S (opp %d)', opp_idx));

% --- subplot 1: Mahalanobis ---
ax_maha = subplot(2,1,1); hold on; grid on;
fn_maha = pick_field(maha_cand);
if ~isempty(fn_maha)
    M = get_slice(tt.(fn_maha{1})); % [N x 4]
    for k = 1:n_models
        plot(t, M(:,k), 'Color', mdl_cols(k,:), 'LineWidth', 1.2, ...
            'DisplayName', mdl_names{k});
    end
    ylabel('Mahalanobis [-]', 'Interpreter', 'none');
    legend('show', 'Location', 'best', 'Interpreter', 'none');
else
    title('mmae_mahalanobis not available', 'FontWeight', 'bold', 'Interpreter', 'none');
end
title('MMAE - Mahalanobis Distance per Filter', 'FontWeight', 'bold', 'Interpreter', 'none');
axes(end+1) = ax_maha; %#ok<SAGROW>
mmae_axes(end+1) = ax_maha;

% --- subplot 2: logdet S ---
ax_ls = subplot(2,1,2); hold on; grid on;
if isfield(tt, 'mmae_logdet_s')
    LS2 = get_slice(tt.mmae_logdet_s); % [N x 4]
    for k = 1:n_models
        plot(t, LS2(:,k), 'Color', mdl_cols(k,:), 'LineWidth', 1.2, ...
            'DisplayName', mdl_names{k});
    end
    ylabel('logdet S [-]', 'Interpreter', 'none');
    legend('show', 'Location', 'best', 'Interpreter', 'none');
else
    title('mmae_logdet_s not available', 'FontWeight', 'bold', 'Interpreter', 'none');
end
title('MMAE - logdet S per Filter', 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('t [s]', 'Interpreter', 'none');
axes(end+1) = ax_ls; %#ok<SAGROW>
mmae_axes(end+1) = ax_ls;

%% ===================== FIGURE 3: Mahalanobis + logdet S (COMMON, 4 Q) =====================
% Only if the log contains the "common" variants (absent in some logs).
if isfield(tt,'mmae_mahalanobis_common') || isfield(tt,'mmae_logdet_s_common')
f = f + 1; figure(f); clf;
set(gcf, 'Name', sprintf('MMAE mahalanobis & logdet S COMMON (opp %d)', opp_idx));

% --- subplot 1: Mahalanobis common ---
ax_mahac = subplot(2,1,1); hold on; grid on;
if isfield(tt, 'mmae_mahalanobis_common')
    MC = get_slice(tt.mmae_mahalanobis_common); % [N x ncol] (ncol=1 if shared)
    nc = size(MC,2);
    for k = 1:nc
        if nc == 1
            dn = 'common'; cc = [0 0 0];
        else
            dn = mdl_names{k}; cc = mdl_cols(k,:);
        end
        plot(t, MC(:,k), 'Color', cc, 'LineWidth', 1.2, 'DisplayName', dn);
    end
    ylabel('Mahalanobis common [-]', 'Interpreter', 'none');
    legend('show', 'Location', 'best', 'Interpreter', 'none');
else
    title('mmae_mahalanobis_common not available', 'FontWeight', 'bold', 'Interpreter', 'none');
end
title('MMAE - Mahalanobis (Common)', 'FontWeight', 'bold', 'Interpreter', 'none');
axes(end+1) = ax_mahac; %#ok<SAGROW>
mmae_axes(end+1) = ax_mahac;

% --- subplot 2: logdet S common ---
ax_ldc = subplot(2,1,2); hold on; grid on;
if isfield(tt, 'mmae_logdet_s_common')
    LDC = get_slice(tt.mmae_logdet_s_common); % [N x ncol] (ncol=1 if shared)
    nc = size(LDC,2);
    for k = 1:nc
        if nc == 1
            dn = 'common'; cc = [0 0 0];
        else
            dn = mdl_names{k}; cc = mdl_cols(k,:);
        end
        plot(t, LDC(:,k), 'Color', cc, 'LineWidth', 1.2, 'DisplayName', dn);
    end
    ylabel('logdet S common [-]', 'Interpreter', 'none');
    legend('show', 'Location', 'best', 'Interpreter', 'none');
else
    title('mmae_logdet_s_common not available', 'FontWeight', 'bold', 'Interpreter', 'none');
end
title('MMAE - logdet S (Common)', 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('t [s]', 'Interpreter', 'none');
axes(end+1) = ax_ldc; %#ok<SAGROW>
mmae_axes(end+1) = ax_ldc;
end  % common figure guard

%% ===================== FIGURE 4: acceleration gains (single plot) =====================
f = f + 1; figure(f); clf;
set(gcf, 'Name', sprintf('MMAE gain acc (opp %d)', opp_idx));
ax_g = gca; hold on; grid on;
if isfield(tt, 'mmae_gain_acc')
    G = get_slice(tt.mmae_gain_acc); % [N x 4]
    for k = 1:n_models
        plot(t, G(:,k), 'Color', mdl_cols(k,:), 'LineWidth', 1.2, ...
            'DisplayName', mdl_names{k});
    end
    ylabel('acceleration gain [-]', 'Interpreter', 'none');
    legend('show', 'Location', 'best', 'Interpreter', 'none');
else
    title('mmae_gain_acc not available', 'FontWeight', 'bold', 'Interpreter', 'none');
end
title('MMAE - Acceleration Gains per Filter', 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('t [s]', 'Interpreter', 'none');
axes(end+1) = ax_g; %#ok<SAGROW>
mmae_axes(end+1) = ax_g;

%% ===================== TABLE: percent differences + absolute medians =====================
% MMAE weights evolve ~ exp(-0.5*(mahalanobis + logdet_s)). We normalize each
% metric against the REFERENCE filter (lowest Q): diffpct_k = (X_k - X_ref)/|X_ref|*100.
% If the other filters stay within a few percent of the reference, the likelihoods are
% indistinguishable -> weights don't discriminate -> the Markov bank is structurally unsuited.

q_ref_idx = 1;   % index of the lowest-Q filter (adjust if the order differs)

ref_metrics = {};   % {name, values [N x nf]}
if isfield(tt,'mmae_gain_acc')
    ref_metrics(end+1,:) = {'acceleration gains',      get_slice(tt.mmae_gain_acc)};   %#ok<SAGROW>
end
if isfield(tt,'mmae_mahalanobis')
    ref_metrics(end+1,:) = {'residuals (Mahalanobis)', get_slice(tt.mmae_mahalanobis)}; %#ok<SAGROW>
end
if isfield(tt,'mmae_logdet_s')
    ref_metrics(end+1,:) = {'logdet S',                get_slice(tt.mmae_logdet_s)};    %#ok<SAGROW>
end

if ~isempty(ref_metrics)
    nm = size(ref_metrics,1);
    nf = size(ref_metrics{1,2}, 2);                 % actual number of filters
    q_ref_idx = min(max(q_ref_idx,1), nf);
    Qf = Q_values(1:nf);                              % Q values for the filters present

    Metric = strings(nm,1);
    Dmed   = nan(nm, nf);   % time-median of diff percent vs reference, per filter
    AbsMed = nan(nm, nf);   % time-median of absolute value, per filter
    for i = 1:nm
        Metric(i) = ref_metrics{i,1};
        X = ref_metrics{i,2};                       % [N x nf]
        if size(X,2) < 2; continue; end
        ref = X(:, q_ref_idx);
        D = (X - ref) ./ max(abs(ref), eps) * 100;  % [N x nf] diff percent per sample
        for k = 1:nf
            dk = D(:,k); dk = dk(isfinite(dk));
            if ~isempty(dk); Dmed(i,k) = median(dk); end
            xk = X(:,k); xk = xk(isfinite(xk));
            if ~isempty(xk); AbsMed(i,k) = median(xk); end
        end
    end

    % table: rows = metrics, columns = filters (median diff percent vs Q-min filter)
    filt_ids    = arrayfun(@(q) sprintf('Q%d', q), Qf, 'uni', false);
    filt_labels = arrayfun(@(q) sprintf('Q = %d', q), Qf, 'uni', false);
    filt_ids{q_ref_idx}    = sprintf('Q%d_ref', Qf(q_ref_idx));
    filt_labels{q_ref_idx} = sprintf('Q = %d (ref)', Qf(q_ref_idx));

    % --- Table 1: median diff percent vs reference ---
    T_ref = array2table(Dmed, 'VariableNames', filt_ids, 'RowNames', cellstr(Metric));
    fprintf('\n=== MMAE: median diff%% vs lowest-Q filter (Q = %d) ===\n', Qf(q_ref_idx));
    disp(T_ref);
    fprintf(['Reading: each number shows by how much percent that filter deviates from the reference (Q-min).\n' ...
             'If the columns stay within a few percent (close to 0), the filters are effectively the same model\n' ...
             '=> indistinguishable likelihoods => MMAE weights do not separate: Markov bank structurally unsuited.\n\n']);

    % --- Table 2: absolute median values for Mahalanobis and logdet S ---
    maha_row = find(contains(Metric, 'Mahalanobis'), 1);
    logd_row = find(contains(Metric, 'logdet'),      1);
    abs_rows = [maha_row, logd_row];
    abs_rows = abs_rows(~cellfun(@isempty, num2cell(abs_rows)));

    fprintf('=== MMAE: absolute median values (Mahalanobis and logdet S) ===\n');
    fprintf('%-30s', 'Metric');
    for k = 1:nf; fprintf('  %14s', filt_labels{k}); end
    fprintf('\n%s\n', repmat('-', 1, 30 + 16*nf));
    for i = abs_rows
        fprintf('%-30s', Metric(i));
        for k = 1:nf
            fprintf('  %14.4f', AbsMed(i,k));
        end
        fprintf('\n');
    end
    fprintf('\n');

    % --- DECISIVE metric: log-likelihood difference and implied weight ratio ---
    if isfield(tt,'mmae_mahalanobis') && isfield(tt,'mmae_logdet_s')
        MA = get_slice(tt.mmae_mahalanobis);
        LS = get_slice(tt.mmae_logdet_s);
        LL = -0.5*(MA + LS);                         % [N x nf] log-likelihood (up to a constant)
        nf2 = size(LL,2); qr = min(max(q_ref_idx,1), nf2);
        Qf2 = Q_values(1:nf2);
        Dll      = nan(nf2,1);
        WratioMed = nan(nf2,1);
        for k = 1:nf2
            d = LL(:,k) - LL(:,qr); d = d(isfinite(d));
            if ~isempty(d); Dll(k) = median(d); WratioMed(k) = exp(median(d)); end
        end
        Q_col = Qf2(:);
        T_ll = table(Q_col, Dll, WratioMed, ...
            'VariableNames', {'Q','Dloglik_vs_ref_nat','Weight_ratio_vs_ref'});
        fprintf('=== MMAE: effective separability (what actually moves the weights) ===\n');
        disp(T_ll);
        fprintf(['Dloglik ~ 0 (and weight ratio ~ 1) => the weights CANNOT diverge from the reference:\n' ...
                 'gains differ by hundreds of percent, but residuals and logdet S cancel out in the\n' ...
                 'log-likelihood => the Markov bank is structurally unable to select the model.\n\n']);
    end

    % --- figure: grouped bars of diff percent per metric and filter (categorical x-axis, not linked) ---
    f = f + 1; figure(f); clf;
    set(gcf,'Name','MMAE - diff percent vs Q-min filter', ...
        'Units', 'pixels', 'Position', [100, 100, 900, 280]);
    hb = bar(Dmed);                                  % groups = metrics, bars = filters
    for k = 1:numel(hb); hb(k).FaceColor = mdl_cols(k,:); end
    set(gca, 'XTick', 1:nm, 'XTickLabel', cellstr(Metric), 'TickLabelInterpreter', 'none');
    grid on;
    ylabel('diff percent vs Q-min reference filter (median)', 'Interpreter', 'none');
    legend(filt_labels, 'Location', 'best', 'Interpreter', 'none');
    title(sprintf('MMAE - Filter Deviation from Q-min Reference (Q = %d)', Qf(q_ref_idx)), ...
        'FontWeight', 'bold', 'Interpreter', 'none');
end

%% ===================== LINK X =====================
% No linkaxes here: XLim linking is handled by the driver (linkprop),
% the MMAE axes have already been added to the global 'axes' array.