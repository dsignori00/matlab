function y = safe_cols(x, max_det)
% SAFE_COLS - Safely select columns for plotting
%
% y = safe_cols(x, max_det) returns x(:,1:max_det) if max_det>0
% or an empty matrix with same number of rows if max_det=0
%
% Inputs:
%   x       : NxM matrix
%   max_det : scalar, number of valid columns to select
%
% Output:
%   y       : Nxmax_det (or Nx0 if max_det=0)

    if max_det > 0
        y = x(:, 1:max_det);
    else
        y = NaN(size(x,1), 1);  
    end
end
