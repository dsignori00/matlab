function y = my_lp_filt(t,u,f_cutoff,n_poles)
%MY_LP_FILT low pass filtering of unevenly sampled data

if nargin < 4
  n_poles = 1;
end

% Fill NaN
u = fillmissing(u, 'linear');

% Even sampling
ts = mean(diff(t));
t_interp = t(1):ts:t(end);
u_interp = interp1(t, u, t_interp, 'linear', 'extrap');

% Filter
s=tf('s');
low_pass_tc = 1/(s/2/pi/f_cutoff + 1)^n_poles;

y_interp = lsim(low_pass_tc, u_interp, t_interp);

y = interp1(t_interp, y_interp, t);

end

