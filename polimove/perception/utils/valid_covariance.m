function P = valid_covariance(in)
    P = in;   % N x K x 25
    diag_idx = [1 7 13 19 25];
    bad = any(P(:,:,diag_idx) == 0, 3);
    P(repmat(bad, 1, 1, 25)) = NaN;
end