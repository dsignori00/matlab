function s = removeField(s, expandedFieldName)
    % Split the expanded field name into parts
    parts = strsplit(expandedFieldName, '.');
    
    % Recursively navigate the structure according to the path
    s = removeNestedField(s, parts);
end

function s = removeNestedField(s, parts)
    % Base case: if only one part is left, remove that field if it exists
    if numel(parts) == 1
        if isfield(s, parts{1})
            s = rmfield(s, parts{1});
        end
    else
        % Check if the current part exists as a field in the structure
        currentField = parts{1};
        if isfield(s, currentField)
            % Recursively call the function on the nested structure
            s.(currentField) = removeNestedField(s.(currentField), parts(2:end));
        end
    end
end
