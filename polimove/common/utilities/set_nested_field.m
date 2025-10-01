function structure = setNestedField(structure, fieldPath, newValue)
    % Split the fieldPath into parts
    parts = strsplit(fieldPath, '.');
    
    % Start at the root of the structure
    currentStruct = structure;
    
    % Navigate through each part, except the last, to reach the target location
    for i = 1:numel(parts)-1
        % If the field doesn't exist or isn't a structure, create a new structure
        if ~isfield(currentStruct, parts{i}) || ~isstruct(currentStruct.(parts{i}))
            currentStruct.(parts{i}) = struct();
        end
        % Update currentStruct to the next nested level
        currentStruct = currentStruct.(parts{i});
    end
    
    % Set the final field to the new value
    currentStruct.(parts{end}) = newValue;
    
    % Update the original structure with the modified nested structure
    structure = setfield(structure, parts{:}, newValue); 
end
