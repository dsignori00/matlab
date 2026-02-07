function P = valid_covariance(in)
    P = in;   % N x K x 36
    diag_idx = [1 8 15 22 29 36];
    bad = any(P(:,:,diag_idx) == 0, 3);
    P(repmat(bad, 1, 1, 36)) = NaN;
end