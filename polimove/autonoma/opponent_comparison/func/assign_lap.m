function laps = assign_lap(indices)
    % Ensure the input is a row or column vector
    if ~isvector(indices)
        error('Input must be a vector.');
    end
    
    % To avoid jumps in lap when teleporting
    % % Calculate the 90th percentile threshold
    % threshold = prctile(indices, 90);
    % 
    % % Check that the value before the drop is above the 90th percentile
    % high_prev = [false; indices(1:end-1) > threshold];

    % Logical mask dei valori validi
    validMask = ~isnan(indices);
    
    % Differenze solo sui valori validi
    diffs = diff(indices(validMask));
    
    % Trova i punti dove c'è un drop
    dec_indices = [false; diffs < -20];
    
    % Ricostruisci un vettore 'drops' della stessa lunghezza di indices
    drops = false(size(indices));
    drops(validMask) = dec_indices;
    
    % Cumulative sum per i giri
    laps = cumsum(drops) + 1;

end
