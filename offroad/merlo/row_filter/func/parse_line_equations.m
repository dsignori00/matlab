function line_eq = parse_line_equations(log, topic)
%PARSELINEEQUATIONS Summary of this function goes here
%   Detailed explanation goes here
    line_eq = struct();
    line_eq.stamp = log.(topic).stamp;
    line_eq.num_fitted_lines = log.(topic).num_fitted_lines;

    line_eq.coeff = log.(topic).fitted_lines__coeff;

    line_eq.p1   = log.(topic).fitted_lines__p1;
    line_eq.p2   = log.(topic).fitted_lines__p2;
    line_eq.rho   = log.(topic).fitted_lines__rho;
    line_eq.form   = double(log.(topic).fitted_lines__form);
    
    if isfield(log.(topic), 'fitted_lines__associated')
        line_eq.associated = log.(topic).fitted_lines__associated;
    end

    line_eq.x_min   = log.(topic).fitted_lines__x_min;
    line_eq.x_max   = log.(topic).fitted_lines__x_max;
    line_eq.y_min   = log.(topic).fitted_lines__y_min;
    line_eq.y_max   = log.(topic).fitted_lines__y_max;
    line_eq.z_min   = log.(topic).fitted_lines__z_min;
    line_eq.z_max   = log.(topic).fitted_lines__z_max;

    line_eq.num_fitted_lines(line_eq.num_fitted_lines ==0) = nan;
    invalid = (line_eq.p1 == 0);                 % NxM logical
    line_eq.coeff(repmat(invalid, 1, 1, size(line_eq.coeff,3))) = NaN;     
    line_eq.p1(line_eq.p1==0)     = nan;
    line_eq.p2(line_eq.p2==0)     = nan;
    line_eq.rho(line_eq.rho==0)   = nan;
    line_eq.form(invalid)   = nan;
    if(isfield(log.(topic), 'fitted_lines__associated'))
        line_eq.associated(invalid) = nan;
    end
    line_eq.x_min(line_eq.x_min == 0) = nan;
    line_eq.x_max(line_eq.x_max == 0) = nan;
    line_eq.y_min(line_eq.y_min == 0) = nan;
    line_eq.y_max(line_eq.y_max == 0) = nan;
    line_eq.z_min(line_eq.z_min == 0) = nan;
    line_eq.z_max(line_eq.z_max == 0) = nan;

end

