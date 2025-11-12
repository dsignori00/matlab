function [vx_guess] = VehicleLimitsLongSpeedMax(curvature, mux_acc, muy)

global kLongSpeedMin;
global kLongSpeedMax;
global kDownForce; 
global g;

if (curvature < 0.0)
    curvature = -curvature;
end

    vx_squared_num = max(muy * mux_acc * g, 0.0);
    vx_squared_den = max(mux_acc * curvature - mux_acc * muy * kDownForce, 0.0001);
    vx_squared = vx_squared_num / vx_squared_den;
    vx_guess = min(sqrt(vx_squared), 100.0);

    vx_guess = max(vx_guess, kLongSpeedMin);
    vx_guess = min(vx_guess, kLongSpeedMax);
end

