function out = nan_struct(in)
    % Create a struct with same fields as in, filled with NaNs
    out = struct();
    fn = fieldnames(in);
    for i = 1:numel(fn)
        fieldValue = in.(fn{i});
        if isnumeric(fieldValue)
            out.(fn{i}) = nan(size(fieldValue));
        elseif iscell(fieldValue)
            out.(fn{i}) = repmat({NaN}, size(fieldValue));
        else
            out.(fn{i}) = [];
        end
    end
end