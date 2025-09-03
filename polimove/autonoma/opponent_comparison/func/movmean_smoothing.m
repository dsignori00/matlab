function v_out = movmean_smoothing(v_in, WINDOWSIDELEN, N_SMOOTHINGS)

    v_out = v_in;
    WINDOWSIZE = 2*WINDOWSIDELEN + 1;

    for i=1:N_SMOOTHINGS
        v_out_padded = [v_out((end-WINDOWSIDELEN+1):end); v_out; v_out(1:WINDOWSIDELEN)];
        v_out = movmean(v_out_padded, WINDOWSIZE, 'Endpoints', 'discard');
    end

end

