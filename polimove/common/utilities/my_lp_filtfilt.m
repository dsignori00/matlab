function y = my_lp_filtfilt(t,u,f_cutoff)
%MY_LP_FILT low pass acausal filtering of unevenly sampled data

% Fill NaN
u = fillmissing(u, 'linear');

% Even sampling
ts = mean(diff(t));
t_interp = t(1):ts:t(end);
u_interp = interp1(t, u, t_interp, 'linear', 'extrap');

% Filter
s=tf('s');
low_pass_tc = 1/(s/2/pi/f_cutoff + 1);
low_pass_td = c2d(low_pass_tc,ts,'Tustin');
low_pass_num = low_pass_td.Numerator{1};
low_pass_den = low_pass_td.Denominator{1};

y_interp = filtfilt(low_pass_num,low_pass_den, u_interp);

y = interp1(t_interp, y_interp, t);

end

