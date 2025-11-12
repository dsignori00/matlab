function laps = assign_lap(indices)
    % Ensure the input is a row or column vector
    if ~isvector(indices)
        error('Input must be a vector.');
    end

    % Calculate the 90th percentile threshold
    threshold = prctile(indices, 90);

    % Find positions where the index drops
    diffs = diff(indices);
    dec_indices = [false; diffs < 0];

    % Check that the value before the drop is above the 90th percentile
    high_prev = [false; indices(1:end-1) > threshold];

    % Combine both conditions with logical AND
    drops = dec_indices & high_prev;

    % Compute cumulative sum of lap changes
    laps = cumsum(drops) + 1;
end
