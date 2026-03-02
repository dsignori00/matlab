function P = valid_covariance(in)

    n3 = size(in,3);
    if n3 == 36
        P = in;

    elseif n3 == 25
        % yaw rate missing, remapping 5x5 -> 6x6 (NaN in 5th row/col)
        [nx, ny, ~] = size(in);
        P5 = reshape(in, nx, ny, 5, 5);
        P6 = NaN(nx, ny, 6, 6);
        idx = [1 2 3 4 6];
        P6(:,:,idx,idx) = P5;
        P = reshape(P6, nx, ny, 36);
    else
        error('Unexpected covariance matrix size: %d', n3);
    end

    diag_idx = [1 8 15 22 29 36];
    bad = any(P(:,:,diag_idx) == 0, 3);

    % set all 36 elements to NaN where bad
    P2 = reshape(P, [], 36);
    P2(reshape(bad, [], 1), :) = NaN;
    P = reshape(P2, size(P));

end