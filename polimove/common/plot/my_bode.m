function [mag_db,phase_deg,lag_ms] = my_bode(tf,f_vect,starting_phase)

omega_vect = 2*pi*f_vect;

[mag,phase_deg] = bode(tf,omega_vect);
mag = squeeze(mag);
phase_deg = squeeze(phase_deg);
if phase_deg(1) >= starting_phase+180
    phase_deg = phase_deg - 360;
elseif phase_deg(1) <= starting_phase-180
    phase_deg = phase_deg + 360;
end
mag_db = mag2db(mag);
lag_ms = phase_deg * pi/180 ./ omega_vect * 1000;