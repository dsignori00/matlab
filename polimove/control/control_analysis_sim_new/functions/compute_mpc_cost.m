function [cost_n, cost_mu, cost_v, cost_r_ref_diff, cost_ax_ref_diff, cost_slack]  ...
    = compute_mpc_cost(mpc_data, Qn, Qmu, Qv, W_r_ref_diff, W_ax_ref_diff, Qslack, use_multipliers)
% Computes the cost function terms of the MPC

%% Compute cost

% Initialize vectors
cost_n = zeros(size(mpc_data.bag_stamp));
cost_mu = zeros(size(mpc_data.bag_stamp));
cost_v = zeros(size(mpc_data.bag_stamp));
cost_r_ref_diff = zeros(size(mpc_data.bag_stamp));
cost_ax_ref_diff = zeros(size(mpc_data.bag_stamp));
cost_slack = zeros(size(mpc_data.bag_stamp));

% Compute cost function terms
for i = 2 : length(cost_n)

    % Lateral error
    weight_n = Qn;
    if use_multipliers
        weight_n = weight_n * mpc_data.cost_lateral_error_mult(i);
        weight_n_terminal = weight_n * mpc_data.cost_terminal_mult(i);
    else
        weight_n_terminal = weight_n;
    end
    cost_n(i) = weight_n * sum(mpc_data.horizon_lateral_error(i,1:end-1).^2) ...
        + weight_n_terminal * mpc_data.horizon_lateral_error(i,end).^2;
    
    % Heading error
    weight_mu = Qmu;
    if use_multipliers
        weight_mu = weight_mu * mpc_data.cost_heading_error_mult(i);
        weight_mu_terminal = weight_mu * mpc_data.cost_terminal_mult(i);
    else
        weight_mu_terminal = weight_mu;
    end
    cost_mu(i) = weight_mu * sum(mpc_data.horizon_heading_error(i,1:end-1).^2) ...
        + weight_mu_terminal * mpc_data.horizon_heading_error(i,end).^2;
    
    % Speed
    weight_v = Qv;
    if use_multipliers
        weight_v = weight_v * mpc_data.cost_speed_mult(i);
        weight_v_terminal = weight_v * mpc_data.cost_terminal_mult(i);
    else
        weight_v_terminal = weight_v;
    end
    cost_v(i) = weight_v * sum((mpc_data.horizon_long_speed_ref(i,1:end-1)-mpc_data.horizon_long_speed(i,1:end-1)).^2) ...
        + weight_v_terminal * sum((mpc_data.horizon_long_speed_ref(i,end)-mpc_data.horizon_long_speed(i,end)).^2); 
       % - weight_v * sum((mpc_data.horizon_long_speed_ref(i,:).^2));

    
    % Reference yaw rate differences
    cost_r_ref_diff(i) = W_r_ref_diff * sum(diff([mpc_data.yaw_rate_ref(i-1) mpc_data.horizon_yaw_rate_ref(i,:)]).^2); 
       %- W_r_ref_diff * mpc_data.yaw_rate_ref(i-1)^2;

    % Reference long. acc. differences
    cost_ax_ref_diff(i) = W_ax_ref_diff * sum(diff([mpc_data.long_acc_ref(i-1) mpc_data.horizon_long_acc_ref(i,:)]).^2); 
       % - W_ax_ref_diff * mpc_data.long_acc_ref(i-1)^2;

    % Slack variable
    cost_slack(i) = Qslack * sum(mpc_data.horizon_slack_ay_error(i,:).^2);

end


end

