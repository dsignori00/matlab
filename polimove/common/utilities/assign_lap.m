function laps = assign_lap(idxs)
    % Ensure the input is a row or column vector
    if ~isvector(idxs)
        error('Input must be a vector.');
    end
    val = idxs~=0;
    indices = idxs(val);

    % Calculate the 90th percentile threshold
    threshold = prctile(indices, 90);

    % Find positions where the index drops
    diffs = diff(indices);
    dec_indices = [false; diffs < -30];

    % Check that the value before the drop is above the 90th percentile
    high_prev = [false; indices(1:end-1) > threshold];

    % Combine both conditions with logical AND
    drops = dec_indices & high_prev;

    % Compute cumulative sum of lap changes
    lapss = cumsum(drops) + 1;

    laps = NaN(size(idxs));
    laps(val) = lapss;
end
