    function laps = AssignLap(indices)
        % Ensure the input is a row or column vector
        if ~isvector(indices)
            error('Input must be a vector.');
        end

        % Find positions where the index drops (new lap starts)
        drops = [false; diff(indices) < 0]; 

        % Compute cumulative sum of lap changes
        laps = cumsum(drops) + 1;
    end
