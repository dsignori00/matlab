function track_frame = get_track_frame2D(s_hat,track)

while s_hat > track.Sref(end)
    s_hat=s_hat-track.Sref(end);
end

[~,idx] = min(abs(s_hat-track.Sref));

% Darboux
track_frame.idx = idx;
track_frame.s       = track.Sref(idx); 
track_frame.Omega_z = track.Rho(idx);
track_frame.Phi     = track.Phi(idx);
track_frame.Banking = track.Banking(idx);

% Cartesian
track_frame.x   = track.X(idx);
track_frame.y   = track.Y(idx);
track_frame.z   = track.Z(idx);

track_frame.psi   = track.Theta(idx);

end
