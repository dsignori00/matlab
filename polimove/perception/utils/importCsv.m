function out = importCsv(filename)

    dataLines = [3, Inf];
    
    fid = fopen(filename, 'r');
    fields_names = textscan(fid, '%[^\n]', 1); 
    fields_names = split(fields_names{1}, ',');

    topic_name = sprintf("%s", erase(filename, ".csv"));

    % Modify CSV names for easier data analysys and to replace too long names
    fields_names = strrep(fields_names, "#", "");
    fields_names = strrep(fields_names, "//", "");
    fields_names = strrep(fields_names, "/", "_");

    stp_idx = strcmp(fields_names, 'stamp');
    fields_names(stp_idx)= {topic_name + "_" + "stamp"};

    fields_names = strip(fields_names);
    fields_names = fields_names(strlength(fields_names) > 0);

    
    for i = 1:length(fields_names)
        if length(fields_names{i}) > 63
            %fprintf("Name: %s is too long - Truncated!\n", fields_names{i});
            fields_names{i} = fields_names{i}(1:63);
        end
    end
    fields_names = string(fields_names)';

    % Set up the Import Options and import the data
    opts = detectImportOptions(filename, 'Delimiter',',', 'NumVariables', length(fields_names));
        
    % Specify column names and types
    opts.DataLines = dataLines;
    opts.VariableNames = fields_names;
    opts.SelectedVariableNames = fields_names;

    % Import the data
    out = readtable(filename, opts);

end
