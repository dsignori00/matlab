%% R_ADAPTIVE_MULTISENSOR
%
% Adaptive R analysis (error-range correlation + prior R_near+beta*rho^2 +
% IAE alpha tuning) for ALL sensors, with a final summary table.
%
% For each sensor, estimates:
%   - baseline R (global Gaussian)            R_x0, R_y0
%   - R_near (short range) and beta           prior R(rho) = R_near + beta*rho^2
%   - precision-weighted sigma-range corr.    r_x, r_y
%   - optimal IAE alpha (from RMSE vs f_c)    a_x, a_y
%   - linear / quadratic / cubic R(rho) fits, compared via weighted RMSE
%
% BIN WEIGHTING — controlled by weight_mode parameter:
%
%   'precision'  (original)
%       w_b = (n_b - 1) / (2 * R_b^2)
%       Inverse asymptotic variance of the sample-variance estimator
%       (delta method). Optimal for estimating each R_b accurately,
%       but DOWN-WEIGHTS high-variance bins (i.e. far-range bins) and
%       therefore SUPPRESSES the observed range-error correlation.
%       Use only if the goal is unbiased estimation of absolute R values.
%
%   'count'  (recommended for correlation analysis)
%       w_b = n_b
%       Weights only by sample count. All bins contribute equally to the
%       trend regardless of their variance level. Does not penalise
%       far-range bins simply for having higher R. Best choice when the
%       goal is to detect and quantify the R(rho) slope.
%
%   'cv'  (intermediate)
%       w_b = sqrt(n_b - 1) / R_b
%       Reciprocal of the relative standard error of R_b. Balances
%       sample size and scale without the quadratic suppression of
%       'precision'. A reasonable compromise.
%
%   'uniform'
%       w_b = 1  (no weighting)
%       Unweighted Pearson correlation / OLS on binned values.
%       Useful as a sanity-check baseline.

if ~exist('sensors','var'); error('R_adaptive_multisensor: "sensors" not found.'); end
if ~exist('gt','var');      error('R_adaptive_multisensor: "gt" not found.');      end
if ~exist('err_thr','var'); err_thr = 10; end

%% ---------------- PARAMETERS ----------------
pos_thr       = 15.0;
range_var     = 'total';      % 'long' = x_rel | 'total' = hypot(x,y)
bin_mode      = 'fixed';     % 'fixed' (default) | 'quantile'
n_bins        = 18;          % used only if bin_mode = 'quantile'
bin_width     = 5.0;         % used only if bin_mode = 'fixed'
min_per_bin   = 50;
r_near_max    = 25.0;
extrap_safety = 1.5;
var_floor     = 1e-6;        % numerical floor on R_bin to avoid division by zero
fc_list       = [0.02 0.05 0.1 0.2 0.5];
fc_ref        = 0.05;
show_figures  = true;        % true = one correlation figure per sensor
verbose       = false;       % print per-sensor details

% -----------------------------------------------------------------
% WEIGHT MODE — change this to control how bins are weighted.
%
%   'count'     -> w_b = n_b                     [RECOMMENDED for correlation]
%   'cv'        -> w_b = sqrt(n_b-1) / R_b       [intermediate]
%   'precision' -> w_b = (n_b-1) / (2*R_b^2)    [original — suppresses far-range bins]
%   'uniform'   -> w_b = 1                        [baseline]
% -----------------------------------------------------------------
weight_mode = 'count';

% single GT precomputation
[gt_stamp_u, ui_gt] = unique(gt.stamp(:));
yaw_gt_u = gt.yaw_map(ui_gt);

n_sens = numel(sensors);

% results container
RES = struct('name',{}, 'R_x0',{},'R_y0',{}, 'Rnear_x',{},'Rnear_y',{}, ...
             'beta_x',{},'beta_y',{}, 'r_x',{},'r_y',{}, ...
             'a_x',{},'a_y',{}, 'fc_x',{},'fc_y',{}, ...
             'Rcap_x',{},'Rcap_y',{}, 'rho_cov',{}, 'n_valid',{}, ...
             'rmse_lin_x',{},'rmse_quad_x',{},'rmse_cub_x',{},'best_x',{}, ...
             'rmse_lin_y',{},'rmse_quad_y',{},'rmse_cub_y',{},'best_y',{});

fprintf('\n========== R ADAPTIVE MULTI-SENSOR ==========\n');
fprintf('  weight_mode = ''%s''\n\n', weight_mode);

for ksen = 1:n_sens

    name  = sensors{ksen}.name;
    s     = sensors{ksen}.s;
    col_k = sensors{ksen}.col;

    % --- error extraction in the relative frame ---
    if ~isfield(s,'x_map_err') || ~isfield(s,'y_map_err') || ~isfield(s,'sens_stamp')
        fprintf('  [%s] missing fields, skipping.\n', name);
        continue;
    end

    x_map_err  = s.x_map_err;
    y_map_err  = s.y_map_err;
    n_cols     = size(x_map_err, 2);
    sens_stamp = repmat(s.sens_stamp, 1, n_cols);

    % anti-outlier gate
    x_rel_err_all = s.x_rel_err;
    y_rel_err_all = s.y_rel_err;
    if size(x_rel_err_all,2) < n_cols
        x_rel_err_all = repmat(x_rel_err_all(:,1), 1, n_cols);
        y_rel_err_all = repmat(y_rel_err_all(:,1), 1, n_cols);
    end
    gate_mask = hypot(x_rel_err_all, y_rel_err_all) < pos_thr;

    x_map_err  = x_map_err(:);  y_map_err = y_map_err(:);
    sens_stamp = sens_stamp(:); gate_mask = gate_mask(:);

    valid = ~isnan(x_map_err) & ~isnan(y_map_err) & ~isnan(sens_stamp) & gate_mask;
    x_map_err = x_map_err(valid); y_map_err = y_map_err(valid);
    sens_stamp = sens_stamp(valid);

    if numel(sens_stamp) < 10*min_per_bin
        fprintf('  [%s] too few samples (%d), skipping.\n', name, numel(sens_stamp));
        continue;
    end

    % rotation to the relative frame
    psi_gt = interp1(gt_stamp_u, yaw_gt_u, sens_stamp, 'linear', nan);
    okp = ~isnan(psi_gt);
    x_map_err = x_map_err(okp); y_map_err = y_map_err(okp);
    sens_stamp = sens_stamp(okp); psi_gt = psi_gt(okp);

    e_x =  cos(psi_gt).*x_map_err + sin(psi_gt).*y_map_err;
    e_y = -sin(psi_gt).*x_map_err + cos(psi_gt).*y_map_err;

    keep = hypot(e_x, e_y) < err_thr;
    e_x = e_x(keep); e_y = e_y(keep); sens_stamp = sens_stamp(keep);

    % true range from GT
    xr_gt = interp1(gt_stamp_u, gt.x_rel(ui_gt), sens_stamp, 'linear', nan);
    yr_gt = interp1(gt_stamp_u, gt.y_rel(ui_gt), sens_stamp, 'linear', nan);
    switch range_var
        case 'long';  rho = abs(xr_gt);          rho_lbl = '|x_{rel}|  [m]';
        case 'total'; rho = hypot(xr_gt, yr_gt); rho_lbl = '\rho  [m]';
    end
    okr = ~isnan(rho);
    e_x = e_x(okr); e_y = e_y(okr); rho = rho(okr); sens_stamp = sens_stamp(okr);

    if numel(rho) < 5*min_per_bin
        fprintf('  [%s] too few samples after gating (%d), skipping.\n', name, numel(rho));
        continue;
    end

    % Gaussian baseline
    sigma_x0 = std(e_x,'omitnan'); R_x0 = sigma_x0^2;
    sigma_y0 = std(e_y,'omitnan'); R_y0 = sigma_y0^2;

    % --- binning ---
    switch bin_mode
        case 'quantile'
            edges = unique(quantile(rho, linspace(0,1,n_bins+1)));
        case 'fixed'
            edges = floor(min(rho)) : bin_width : ceil(max(rho))+bin_width;
    end
    nb = numel(edges)-1;
    bc = nan(nb,1); Rx_bin = nan(nb,1); Ry_bin = nan(nb,1); cnt_bin = zeros(nb,1);
    for b = 1:nb
        if b < nb; in = rho>=edges(b) & rho<edges(b+1);
        else;      in = rho>=edges(b) & rho<=edges(b+1); end
        cnt_bin(b) = nnz(in);
        if cnt_bin(b) >= min_per_bin
            bc(b) = median(rho(in));
            Rx_bin(b) = var(e_x(in),'omitnan');
            Ry_bin(b) = var(e_y(in),'omitnan');
        end
    end
    vb = ~isnan(bc); bc_v = bc(vb); cnt_v = cnt_bin(vb);

    if nnz(vb) < 3
        fprintf('  [%s] fewer than 3 valid bins, skipping.\n', name);
        continue;
    end

    Rx_v = max(Rx_bin(vb), var_floor);
    Ry_v = max(Ry_bin(vb), var_floor);

    % -----------------------------------------------------------------
    % BIN WEIGHTS — selected by weight_mode
    %
    % 'precision':  w = (n-1)/(2*R^2)  [original]
    %   Optimal estimator precision, but penalises high-variance (far)
    %   bins and therefore suppresses the range-error correlation signal.
    %
    % 'count':  w = n  [recommended]
    %   Weight only by sample count. Far-range bins are not penalised for
    %   having legitimately higher variance. Reveals the true correlation.
    %
    % 'cv':  w = sqrt(n-1)/R  [intermediate]
    %   Inverse relative SE of R_b. Balances size and scale without the
    %   quadratic suppression of 'precision'.
    %
    % 'uniform':  w = 1
    %   No weighting; equivalent to unweighted Pearson on binned values.
    % -----------------------------------------------------------------
    switch weight_mode
        case 'precision'
            w_bin_x = (cnt_v - 1) ./ (2 * Rx_v.^2);
            w_bin_y = (cnt_v - 1) ./ (2 * Ry_v.^2);
        case 'count'
            w_bin_x = cnt_v;
            w_bin_y = cnt_v;
        case 'cv'
            w_bin_x = sqrt(cnt_v - 1) ./ Rx_v;
            w_bin_y = sqrt(cnt_v - 1) ./ Ry_v;
        case 'uniform'
            w_bin_x = ones(size(cnt_v));
            w_bin_y = ones(size(cnt_v));
        otherwise
            error('Unknown weight_mode: ''%s''. Use ''count'', ''cv'', ''precision'', or ''uniform''.', weight_mode);
    end

    % --- precision-weighted sigma-range correlation ---
    sig_x_bin = sqrt(Rx_bin(vb)); sig_y_bin = sqrt(Ry_bin(vb));
    wcorr = @(a,b,w) ( sum(w.*(a-sum(w.*a)/sum(w)).*(b-sum(w.*b)/sum(w))) ) / ...
            sqrt( sum(w.*(a-sum(w.*a)/sum(w)).^2) * sum(w.*(b-sum(w.*b)/sum(w)).^2) );
    r_x = wcorr(bc_v, sig_x_bin, w_bin_x);
    r_y = wcorr(bc_v, sig_y_bin, w_bin_y);

    % --- R_near + beta*rho^2 prior fit (WLS) ---
    rho2 = bc_v.^2;
    X = [ones(numel(bc_v),1), rho2];

    Wdx = diag(w_bin_x);
    coef_x = (X'*Wdx*X) \ (X'*Wdx*Rx_bin(vb));
    Rnear_x = max(0,coef_x(1)); beta_x = max(0,coef_x(2));

    Wdy = diag(w_bin_y);
    coef_y = (X'*Wdy*X) \ (X'*Wdy*Ry_bin(vb));
    Rnear_y = max(0,coef_y(1)); beta_y = max(0,coef_y(2));

    % extrapolation cap
    rho_cov = max(bc_v);
    Rcap_x = extrap_safety*(Rnear_x + beta_x*rho_cov^2);
    Rcap_y = extrap_safety*(Rnear_y + beta_y*rho_cov^2);

    % --- R(rho) model comparison: linear / quadratic / cubic ---
    nvb = numel(bc_v);
    [coef_lin_x, rmse_lin_x] = wls_polyfit(bc_v, Rx_bin(vb), w_bin_x, 1);
    [coef_lin_y, rmse_lin_y] = wls_polyfit(bc_v, Ry_bin(vb), w_bin_y, 1);

    if nvb >= 3
        [coef_quad_x, rmse_quad_x] = wls_polyfit(bc_v, Rx_bin(vb), w_bin_x, 2);
        [coef_quad_y, rmse_quad_y] = wls_polyfit(bc_v, Ry_bin(vb), w_bin_y, 2);
    else
        coef_quad_x = nan(3,1); rmse_quad_x = nan;
        coef_quad_y = nan(3,1); rmse_quad_y = nan;
    end

    if nvb >= 4
        [coef_cub_x, rmse_cub_x] = wls_polyfit(bc_v, Rx_bin(vb), w_bin_x, 3);
        [coef_cub_y, rmse_cub_y] = wls_polyfit(bc_v, Ry_bin(vb), w_bin_y, 3);
    else
        coef_cub_x = nan(4,1); rmse_cub_x = nan;
        coef_cub_y = nan(4,1); rmse_cub_y = nan;
    end

    models_lbl = {'linear','quadratic','cubic'};
    [~, ibest_x] = min([rmse_lin_x, rmse_quad_x, rmse_cub_x]);
    [~, ibest_y] = min([rmse_lin_y, rmse_quad_y, rmse_cub_y]);
    best_x = models_lbl{ibest_x};
    best_y = models_lbl{ibest_y};

    % --- IAE alpha tuning (RMSE vs f_c) ---
    [t_s, ui] = unique(sens_stamp);
    ex_s = e_x(ui); ey_s = e_y(ui); rho_s = rho(ui);
    prior_x = min(Rnear_x + beta_x*rho_s.^2, Rcap_x);
    prior_y = min(Rnear_y + beta_y*rho_s.^2, Rcap_y);
    HPH_x = Rnear_x; HPH_y = Rnear_y;

    dt = median(diff(t_s),'omitnan'); fs = 1/dt;
    alphas = 1 - exp(-2*pi*fc_list*dt);
    wlen = max(3, round(fs/(2*fc_ref)));
    Rx_true = movvar(ex_s, wlen, 'omitnan','Endpoints','shrink');
    Ry_true = movvar(ey_s, wlen, 'omitnan','Endpoints','shrink');

    na = numel(alphas); rmse_x = zeros(na,1); rmse_y = zeros(na,1);
    for ia = 1:na
        a = alphas(ia);
        Rx = zeros(size(ex_s)); Ry = zeros(size(ey_s));
        Rx(1)=prior_x(1); Ry(1)=prior_y(1);
        Rx_iae=prior_x(1); Ry_iae=prior_y(1);
        for kk = 2:numel(ex_s)
            Rx_iae = (1-a)*Rx_iae + a*(ex_s(kk)^2 - HPH_x);
            Ry_iae = (1-a)*Ry_iae + a*(ey_s(kk)^2 - HPH_y);
            Rx(kk) = max(prior_x(kk), Rx_iae);
            Ry(kk) = max(prior_y(kk), Ry_iae);
        end
        rmse_x(ia) = sqrt(mean((Rx-Rx_true).^2,'omitnan'));
        rmse_y(ia) = sqrt(mean((Ry-Ry_true).^2,'omitnan'));
    end
    [~,bx] = min(rmse_x); [~,by] = min(rmse_y);

    % --- save results ---
    RES(end+1) = struct('name',name, 'R_x0',R_x0,'R_y0',R_y0, ...
        'Rnear_x',Rnear_x,'Rnear_y',Rnear_y, 'beta_x',beta_x,'beta_y',beta_y, ...
        'r_x',r_x,'r_y',r_y, 'a_x',alphas(bx),'a_y',alphas(by), ...
        'fc_x',fc_list(bx),'fc_y',fc_list(by), ...
        'Rcap_x',Rcap_x,'Rcap_y',Rcap_y, 'rho_cov',rho_cov, 'n_valid',numel(rho), ...
        'rmse_lin_x',rmse_lin_x,'rmse_quad_x',rmse_quad_x,'rmse_cub_x',rmse_cub_x,'best_x',best_x, ...
        'rmse_lin_y',rmse_lin_y,'rmse_quad_y',rmse_quad_y,'rmse_cub_y',rmse_cub_y,'best_y',best_y); %#ok<SAGROW>

    if verbose
        fprintf('  [%s] R0=(%.2f,%.2f) Rnear=(%.2f,%.2f) beta=(%.2e,%.2e) r=(%.2f,%.2f)\n', ...
            name, R_x0,R_y0, Rnear_x,Rnear_y, beta_x,beta_y, r_x,r_y);
    end

    % --- per-sensor correlation figure (optional) ---
    if show_figures
        figure('Name',sprintf('Error vs range correlation - %s',upper(name)), ...
            'Color','w','Position',[80 80 1100 480]);
        tiledlayout(1,2,'Padding','compact','TileSpacing','loose');

        chans   = {e_x,e_y};
        Rbins   = {Rx_bin,Ry_bin};
        R0s     = {R_x0,R_y0};
        rs      = {r_x,r_y};
        coefs_l = {coef_lin_x,  coef_lin_y};
        coefs_q = {coef_quad_x, coef_quad_y};
        coefs_c = {coef_cub_x,  coef_cub_y};
        rmses   = {[rmse_lin_x rmse_quad_x rmse_cub_x], [rmse_lin_y rmse_quad_y rmse_cub_y]};
        ttls    = {'Longitudinal','Lateral'};
        ylbls   = {'|e_x|  [m]','|e_y|  [m]'};

        for d = 1:2
            nexttile; hold on; grid on; box on;

            step = max(1,floor(numel(rho)/4000));
            plot(rho(1:step:end), abs(chans{d}(1:step:end)), '.', ...
                'Color',0.6*[1 1 1]+0.4*col_k,'MarkerSize',4,'HandleVisibility','off');

            sig_d = sqrt(Rbins{d}(vb));
            plot(bc_v, sig_d, 'o-','Color',col_k,'LineWidth',1.4, ...
                'MarkerFaceColor',col_k,'MarkerSize',4,'DisplayName','Binned \sigma');

            yline(sqrt(R0s{d}),'--','Color',[0.4 0.4 0.4],'LineWidth',1.1, ...
                'DisplayName','Baseline \sigma');

            rr = linspace(min(bc_v),max(bc_v),150);

            if all(isfinite(coefs_l{d}))
                R_lin_curve = max(0, polyval(flipud(coefs_l{d}), rr));
                plot(rr, sqrt(R_lin_curve), '-', 'Color', [0.20 0.60 0.20], 'LineWidth', 1.6, ...
                    'DisplayName', sprintf('Linear (RMSE %.2f)', rmses{d}(1)));
            end
            if all(isfinite(coefs_q{d}))
                R_quad_curve = max(0, polyval(flipud(coefs_q{d}), rr));
                plot(rr, sqrt(R_quad_curve), '-', 'Color', [0.85 0.20 0.20], 'LineWidth', 1.6, ...
                    'DisplayName', sprintf('Quadratic (RMSE %.2f)', rmses{d}(2)));
            end
            if all(isfinite(coefs_c{d}))
                R_cub_curve = max(0, polyval(flipud(coefs_c{d}), rr));
                plot(rr, sqrt(R_cub_curve), '-', 'Color', [0.30 0.30 0.85], 'LineWidth', 1.6, ...
                    'DisplayName', sprintf('Cubic (RMSE %.2f)', rmses{d}(3)));
            end

            xlabel(rho_lbl,'Interpreter','tex'); ylabel(ylbls{d},'Interpreter','tex');
            title(sprintf('%s  (r=%+.2f)',ttls{d},rs{d}),'Interpreter','none');

            lg = legend('show', 'Location','northeast', 'Interpreter','tex', ...
                'FontSize', 7, 'Box','on', 'AutoUpdate','off');
            try
                lg.BoxFace.ColorType = 'truecoloralpha';
                lg.BoxFace.ColorData = uint8([255;255;255;200]);
            catch
            end
        end
        sgtitle(sprintf('%s — measurement error vs range ', upper(name)), ...
            'FontWeight','bold','FontSize',13,'Interpreter','none');
    end
end

%% ============================ SUMMARY TABLE ============================
fprintf('\n======== R(rho) SUMMARY TABLE PER SENSOR ========\n');
fprintf('  weight_mode = ''%s''\n\n', weight_mode);

% --- LONGITUDINAL COMPONENT (x) ---
fprintf('--- LONGITUDINAL COMPONENT (x) ---\n');
fprintf('%-8s %8s %8s %10s %7s %8s %6s\n', ...
    'sensor','R_x0','R_near','beta_x','r_x','alpha_x','fc');
fprintf('%s\n', repmat('-',1,62));
for i = 1:numel(RES)
    fprintf('%-8s %8.3f %8.3f %10.3e %+7.2f %8.4f %6.2f\n', ...
        RES(i).name, RES(i).R_x0, RES(i).Rnear_x, RES(i).beta_x, ...
        RES(i).r_x, RES(i).a_x, RES(i).fc_x);
end

% --- LATERAL COMPONENT (y) ---
fprintf('\n--- LATERAL COMPONENT (y) ---\n');
fprintf('%-8s %8s %8s %10s %7s %8s %6s\n', ...
    'sensor','R_y0','R_near','beta_y','r_y','alpha_y','fc');
fprintf('%s\n', repmat('-',1,62));
for i = 1:numel(RES)
    fprintf('%-8s %8.3f %8.3f %10.3e %+7.2f %8.4f %6.2f\n', ...
        RES(i).name, RES(i).R_y0, RES(i).Rnear_y, RES(i).beta_y, ...
        RES(i).r_y, RES(i).a_y, RES(i).fc_y);
end

%% ============================ MODEL COMPARISON (linear/quadratic/cubic) ============================
fprintf('\n======== R(rho) MODEL COMPARISON: WEIGHTED RMSE ========\n');
fprintf('  weight_mode = ''%s''\n\n', weight_mode);

fprintf('--- LONGITUDINAL COMPONENT (x) ---\n');
fprintf('%-8s %12s %12s %12s %10s\n', 'sensor','RMSE_lin','RMSE_quad','RMSE_cub','best');
fprintf('%s\n', repmat('-',1,58));
for i = 1:numel(RES)
    fprintf('%-8s %12.4f %12.4f %12.4f %10s\n', RES(i).name, ...
        RES(i).rmse_lin_x, RES(i).rmse_quad_x, RES(i).rmse_cub_x, RES(i).best_x);
end

fprintf('\n--- LATERAL COMPONENT (y) ---\n');
fprintf('%-8s %12s %12s %12s %10s\n', 'sensor','RMSE_lin','RMSE_quad','RMSE_cub','best');
fprintf('%s\n', repmat('-',1,58));
for i = 1:numel(RES)
    fprintf('%-8s %12.4f %12.4f %12.4f %10s\n', RES(i).name, ...
        RES(i).rmse_lin_y, RES(i).rmse_quad_y, RES(i).rmse_cub_y, RES(i).best_y);
end

fprintf('\n[note] weight_mode = ''%s''\n', weight_mode);
switch weight_mode
    case 'count';     fprintf('[note] w_b = n_b  ->  all bins contribute equally to the trend; far-range bins not penalised.\n');
    case 'cv';        fprintf('[note] w_b = sqrt(n_b-1)/R_b  ->  inverse relative SE of R_b.\n');
    case 'precision'; fprintf('[note] w_b = (n_b-1)/(2*R_b^2)  ->  original precision weight; suppresses high-variance bins.\n');
    case 'uniform';   fprintf('[note] w_b = 1  ->  unweighted; equivalent to OLS on binned values.\n');
end
fprintf('[note] lower weighted RMSE = better fit to the binned R(rho) values.\n');

% --- ready-to-use prior formulas ---
fprintf('\n--- PRIOR R(rho) = R_near + beta*rho^2 ---\n');
for i = 1:numel(RES)
    fprintf('  %-8s  R_x = %.3f + %.3e*rho^2   (cap %.2f, rho_cov %.0f m)\n', ...
        RES(i).name, RES(i).Rnear_x, RES(i).beta_x, RES(i).Rcap_x, RES(i).rho_cov);
    fprintf('  %-8s  R_y = %.3f + %.3e*rho^2   (cap %.2f)\n', ...
        '', RES(i).Rnear_y, RES(i).beta_y, RES(i).Rcap_y);
end
fprintf('\n[note] high r (>~0.5) -> R(rho) is justified; low r -> R is nearly constant.\n');
fprintf('========================================================\n\n');

% ===================== local helpers =====================
function [coefs, rmse_w] = wls_polyfit(x, y, w, deg)
% Weighted least squares polynomial fit.
% coefs are in ASCENDING order: y = coefs(1) + coefs(2)*x + coefs(3)*x^2 + ...
% rmse_w is the weighted RMSE of the fit on the input (x,y) points.
    x = x(:); y = y(:); w = w(:);
    X = x.^(0:deg);
    Wd = diag(w);
    coefs = (X.'*Wd*X) \ (X.'*Wd*y);
    yhat  = X*coefs;
    resid = y - yhat;
    rmse_w = sqrt( sum(w.*resid.^2) / sum(w) );
end