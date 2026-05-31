function out = importCsv(filename)

    dataLines = [3, Inf];
    
    fid = fopen(filename, 'r');
    fields_names = textscan(fid, '%[^\n]', 1); 
    fields_names = split(fields_names{1}, ',');

    % Set up the Import Options and import the data
    opts = detectImportOptions(filename, 'Delimiter',',', 'NumVariables', length(fields_names));
        
    % Specify column names and types
    opts.DataLines = dataLines;
    opts.VariableNames = fields_names;
    opts.SelectedVariableNames = fields_names;

    % Import the data
    out = readtable(filename, opts);

end
