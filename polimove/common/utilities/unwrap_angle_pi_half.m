function angle_out = unwrap_angle_pi_half(angle_in, angle_ref)
% UNWRAP_ANGLE_PI_HALF  Robust, vectorized angle unwrapping relative to a reference.
%
%   angle_out = unwrap_angle_pi_half(angle_in, angle_ref)
%
% Ensures that (angle_ref - angle_out) ∈ (-pi/2, pi/2], even if
% angle_in and angle_ref differ by more than π.
% Works for vectors or matrices of equal size.

    diff = angle_ref - angle_in;
    diff_wrapped = mod(diff + pi/4, pi/2) - pi/4;
    diff_wrapped(diff_wrapped == -pi/4) = pi/4;
    angle_out = angle_ref - diff_wrapped;
end
