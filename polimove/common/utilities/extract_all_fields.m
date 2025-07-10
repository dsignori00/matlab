function fields = extractAllFields(s)
    %EXTRACTALLFIELDS Summary of this function goes here
    %   Detailed explanation goes here
    fields = {};  % Initialize an empty cell array to store field information
    
    % Call the recursive helper function
    fields = extractFieldsRecursive(s, fields, '');
end

function fields = extractFieldsRecursive(s, fields, prefix)
    % Check if the input is a struct
    if isstruct(s)
        fieldNames = fieldnames(s);  % Get the field names of the struct
        
        for i = 1:numel(fieldNames)
            fieldName = fieldNames{i};
            fullFieldName = [prefix '.' fieldName];
            
            % Check if the field is itself a struct (nested case)
            if isstruct(s.(fieldName))
                % Recursively call the helper function for the nested struct
                fields = extractFieldsRecursive(s.(fieldName), fields, fullFieldName);
            else
                % Otherwise, add the field name and its value to the fields list
                fields{end+1, 1} = fullFieldName(2:end);  % Remove leading dot
%                 fields{end, 2} = s.(fieldName);  % Store field value
            end
        end
    end
end

