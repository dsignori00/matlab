function value = get_nested_field(structure, fieldPath)
    % Split the path into parts
    parts = strsplit(fieldPath, '.');
    
    % Start with the input structure
    value = structure;
    
    % Navigate through each part of the path
    for i = 1:numel(parts)
        % Access the field at the current level
        if isfield(value, parts{i})
            value = value.(parts{i});
        else
            error('Field "%s" not found in the structure.', parts{i});
        end
    end
end
