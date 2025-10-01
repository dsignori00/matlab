function [vx_dot] = VehicleLimitsLongAccMax(curvature, vx, mux_acc, muy, n_exp)

global kDrag; 
global kDownForce; 
global g;

max_power = 373.161;
max_power = 350;

den = max((g + kDownForce * vx * vx )^n_exp - (abs( ( vx * vx * curvature ) / muy ) )^n_exp, 0);
vx_dot = max(0.0, mux_acc * den^(1/n_exp) ) - kDrag * vx * vx;
vx_dot = min(vx_dot, max_power/vx - kDrag * vx * vx);

end

