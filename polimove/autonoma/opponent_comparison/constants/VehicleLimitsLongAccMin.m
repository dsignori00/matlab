function [vx_dot] = VehicleLimitsLongAccMin(curvature, vx, mux_dec, muy, n_exp)
 
global kDrag;
global kDownForce; 
global g; 

den = max((g + kDownForce * vx * vx )^n_exp - (abs( ( vx * vx * curvature ) / muy ) )^n_exp, 0);
vx_dot = min(0.0, - mux_dec * den^(1/n_exp) ) - kDrag * vx * vx;

end

