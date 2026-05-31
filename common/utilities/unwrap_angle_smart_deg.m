function angle_out = unwrap_angle_smart_deg(angle_in, angle_ref)
    in = deg2rad(angle_in);
    ref = deg2rad(angle_ref);
    diff = ref - in;
    diff_wrapped = mod(diff + pi, 2*pi) - pi;
    angle_out = ref - diff_wrapped;
    angle_out = rad2deg(angle_out);
end

