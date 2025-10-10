function angle_out = unwrap_angle_smart(angle_in, angle_ref)
% UNWRAP_ANGLE_SMART  Robust, vectorized angle unwrapping relative to a reference.
%
%   angle_out = unwrap_angle_smart(angle_in, angle_ref)
%
% Ensures that (angle_ref - angle_out) ∈ (-pi, pi], even if
% angle_in and angle_ref differ by more than 2π.
% Works for vectors or matrices of equal size.

    diff = angle_ref - angle_in;
    diff_wrapped = mod(diff + pi, 2*pi) - pi;
    angle_out = angle_ref - diff_wrapped;
end

