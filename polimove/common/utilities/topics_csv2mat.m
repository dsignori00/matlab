clc
clearvars
close all
    
sel_path = uigetdir2("", "Choose one or multiple bags");
%%
for p = 1:length(sel_path)
    
    bag_csv_path = fullfile(sel_path{p}, 'Parsed_Data');
    if ~exist(bag_csv_path, 'dir')
        fprintf("ERROR! No Parsed data in: %s\n", sel_path{p});
        continue;
    end
    addpath(bag_csv_path);

    fprintf("\nParsing bag: %s\n\n", sel_path{p});

    topic_list = dir(bag_csv_path + convertCharsToStrings(filesep) + "*.csv");
    topic_list = string({topic_list.name});

    start_bag_timestamp = int64(Inf);
    start_timestamp_sec = int64(Inf);
    start_timestamp_nsec = int64(Inf);

    k = 1;
    i = 1;
    
    %% Read all the csv files
    while i <= length(topic_list)
        
        try
            filename = topic_list(i);

            topic_name = sprintf("%s", erase(filename, ".csv"));
            
            fprintf("Parsing topic: %s\n", topic_name);
            
            eval_string_1 = topic_name + " = importCsv('" + filename + "');";
            eval(eval_string_1);

            eval_string_2 = "fieldnames(" + topic_name + ");";
            fields = eval(eval_string_2);

            timestamp_sec_position = endsWith(fields, 'stamp__sec');
            timestamp_nsec_position = endsWith(fields, 'stamp__nanosec');

            if any(timestamp_sec_position) && any(timestamp_nsec_position)
                sec_fields = find(timestamp_sec_position);
                nsec_fields = find(timestamp_nsec_position);
                for j = 1:length(sec_fields)
                    eval_string_3 = "tmp_sec = int64(" + topic_name + ".(fields{sec_fields(j)})(1));";
                    eval_string_4 = "tmp_nsec = int64(" + topic_name + ".(fields{nsec_fields(j)})(1));";
                    eval(eval_string_3);
                    eval(eval_string_4);

                    if tmp_sec > 1000000000 && (tmp_sec < start_timestamp_sec || (tmp_sec == start_timestamp_sec && tmp_nsec < start_timestamp_nsec) )
                        start_timestamp_sec = tmp_sec;
                        start_timestamp_nsec = tmp_nsec;
                        k = k + 1;
                        %disp('Updated Msg Timestamp');
                    end       
                end
            end

            eval_string_5 = "tmp_bag = int64(" + topic_name + ".(fields{1})(1));";
            eval(eval_string_5);

            if tmp_bag > int64(1000000000000000000) && tmp_bag < start_bag_timestamp
                start_bag_timestamp = tmp_bag;
                %disp('Updated Bag Timestamp');
            end
            
            if find(endsWith(fields, "_1"), 1) ~= 0
                vectorial_fields_names = fields(endsWith(fields, "_1"));
                for j = 1:length(vectorial_fields_names)
                    vectorial_field_name = split(string(vectorial_fields_names(j)), '_1');
                    vectorial_field_name = string(vectorial_field_name(1));
                    all_vector_field_names = fields(find(contains(fields, vectorial_field_name + "_")));
                    if length(all_vector_field_names) == 1
                        continue;
                    end
                    vector_values = split(all_vector_field_names, vectorial_field_name + "_");
                    vector_values = cellfun(@str2double, vector_values(:,2));
                    vector_values = vector_values(~isnan(vector_values));
                    all_vector_field_names = vectorial_field_name + "_" + num2str(vector_values);
                    all_vector_field_names = strrep(all_vector_field_names, " ", "");
                    if length(all_vector_field_names) == 1
                        continue;
                    end
                    max_vector_value = max(vector_values);
                    
                    eval_string_5b = topic_name + "." + vectorial_field_name + " = zeros([length(" + topic_name + ".(string(vectorial_fields_names(j)))) , max_vector_value]);";
                    eval(eval_string_5b);
                    for k = 1:max_vector_value
                        field_numb = find(strcmp(fields, vectorial_field_name + "_" + num2str(k)));
                        eval_string_5c = topic_name + "." + vectorial_field_name + "(:,k) = " + topic_name + ".(string(fields(field_numb)));";
                        eval(eval_string_5c);
                    end
                end
                
                
                for j = 1:length(vectorial_fields_names)
                    vectorial_field_name = split(string(vectorial_fields_names(j)), '_1');
                    vectorial_field_name = string(vectorial_field_name(1));
                    all_vector_field_names = fields(find(contains(fields, vectorial_field_name + "_")));
                    if length(all_vector_field_names) == 1
                        continue;
                    end
                    vector_values = split(all_vector_field_names, vectorial_field_name + "_");
                    vector_values = cellfun(@str2double, vector_values(:,2));
                    vector_values = vector_values(~isnan(vector_values));
                    all_vector_field_names = vectorial_field_name + "_" + num2str(vector_values);
                    all_vector_field_names = strrep(all_vector_field_names, " ", "");
                    if length(all_vector_field_names) == 1
                        continue;
                    end
                    eval_string_5d = topic_name + " = removevars(" + topic_name + ", all_vector_field_names);";
                    eval(eval_string_5d);
                    eval_string_5e = "fields = fieldnames(" + topic_name + ");";
                    eval(eval_string_5e);
                end
            end
            
            if any(contains(fields, "_1_")) && ~any(contains(fields, "raptor_report__motec_warning__"))
                tmp = fields(contains(fields, "_1_"));
                field_names = split(string(tmp), '_1_');
                struct_base_names = unique(field_names(:,1));
                for j = 1:length(struct_base_names)
                    struct_fields_names = split(fields(contains(fields, struct_base_names(j) + "_1_")), struct_base_names(j) + "_1_");
                    struct_fields_names = struct_fields_names(:,2);
                    tmp = split(fields(contains(fields, struct_base_names(j) + "_" + {'1','2','3','4','5','6','7','8','9','0'})), struct_base_names(j) + "_");
                    tmp = tmp(:,2); idxes = zeros(length(tmp),1);
                    for l = 1:length(tmp)
                        idx_number = split(tmp(l), '_');
                        idxes(l) = str2double(idx_number(1));
                    end
                    idxes = unique(idxes);
                    if length(idxes) == 1
                        continue;
                    end
                    tmp = struct_base_names(j) + "_" + num2str(idxes);
                    tmp = strrep(tmp, " ", "");
                    all_struct_field_names = strings(length(struct_fields_names)*length(tmp),1);
                    for l = 1:length(tmp)
                        for q = 1:length(struct_fields_names)
                            all_struct_field_names((l-1)*length(struct_fields_names) + q) = tmp(l) + "_" + struct_fields_names(q);
                        end
                    end
                    all_struct_field_names = strrep(all_struct_field_names, " ", "");
                    if length(all_struct_field_names) == 1
                        continue;
                    end
                    max_idx = max(idxes);
                    
                    for k = 1:length(struct_fields_names)
                        eval_string_5b = topic_name + "." + struct_base_names(j) + "__" + struct_fields_names(k) + " = zeros([length(" + topic_name + ".(all_struct_field_names(k))) , max_idx]);";
                        eval(eval_string_5b);
                        eval_string_5b = topic_name + "." + struct_base_names(j) + "__" + struct_fields_names(k) + " = cast(" + topic_name + "." + struct_base_names(j) + "__" + struct_fields_names(k) + ", class(" + topic_name + ".(all_struct_field_names(k))) );";
                        eval(eval_string_5b);
                        for l = 1:max_idx
                            struct_fields_names_l = split(fields(contains(fields, struct_base_names(j) + "_" + num2str(l) + "_")), struct_base_names(j) + "_" + num2str(l) + "_");
                            struct_fields_names_l = struct_fields_names_l(:,2);
                            field_numb = find(strcmp(fields,  struct_base_names(j) + "_" + num2str(l) + "_" + struct_fields_names_l(k)));
                            eval_string_5c = topic_name + "." + struct_base_names(j) + "__" + struct_fields_names(k) + "(:,l) = " + topic_name + ".(string(fields(field_numb)));";
                            eval(eval_string_5c);
                            
                        end
                    end
                    
                end
                
                for j = 1:length(struct_base_names)
                    struct_fields_names = split(fields(contains(fields, struct_base_names(j) + "_1_")), struct_base_names(j) + "_1_");
                    struct_fields_names = struct_fields_names(:,2);
                    tmp = split(fields(contains(fields, struct_base_names(j) + "_" + {'1','2','3','4','5','6','7','8','9','0'})), struct_base_names(j) + "_");
                    tmp = tmp(:,2); idxes = zeros(length(tmp),1);
                    for l = 1:length(tmp)
                        idx_number = split(tmp(l), '_');
                        idxes(l) = str2double(idx_number(1));
                    end
                    idxes = unique(idxes);
                    if length(idxes) == 1
                        continue;
                    end
                    tmp = struct_base_names(j) + "_" + num2str(idxes);
                    tmp = strrep(tmp, " ", "");
                    all_struct_field_names = strings(length(struct_fields_names)*length(tmp),1);
                    for l = 1:length(tmp)
                        struct_fields_names_l = split(fields(contains(fields, struct_base_names(j) + "_" + num2str(l) + "_")), struct_base_names(j) + "_" + num2str(l) + "_");
                        struct_fields_names_l = struct_fields_names_l(:,2);    
                        for q = 1:length(struct_fields_names)
                            all_struct_field_names((l-1)*length(struct_fields_names) + q) = tmp(l) + "_" + struct_fields_names_l(q);
                        end
                    end
                    all_struct_field_names = strrep(all_struct_field_names, " ", "");
                    if length(all_struct_field_names) == 1
                        continue;
                    end
                    eval_string_5d = topic_name + " = removevars(" + topic_name + ", all_struct_field_names);";
                    eval(eval_string_5d);
                    eval_string_5e = "fields = fieldnames(" + topic_name + ");";
                    eval(eval_string_5e);
                end
            end
            
            i = i + 1;
            
        catch e
            warning("WARNING: Could not parse topic: " + topic_name);
            warning("Error type:  " + e.message);
            topic_list = topic_list([1:i-1,i+1:end]);
        end

    end

    %% Get initial time offset (minimum between bag and msg timestamp

    if start_bag_timestamp > start_timestamp_sec*1e9+start_timestamp_nsec
        zero_bag_timestamp = int64(start_timestamp_sec*1e9+start_timestamp_nsec);
        zero_timestamp_sec = start_timestamp_sec;
        zero_timestamp_nsec = start_timestamp_nsec;
    else
        zero_bag_timestamp = start_bag_timestamp;
        bag_time_str = num2str(start_bag_timestamp);
        bag_time_str_sec = bag_time_str(1:end-9);
        zero_timestamp_sec = int64(str2num(bag_time_str_sec));
        zero_timestamp_nsec = start_bag_timestamp-zero_timestamp_sec*1e9;
    end
    
    log.time_offset_nsec = int64(zero_timestamp_sec)*1e9+int64(zero_timestamp_nsec);
    
    %% Offset all time vectors

    for i = 1:length(topic_list)
        filename = topic_list(i);
        topic_name = sprintf("%s", erase(filename, ".csv"));

        eval_string_6 = "fields = fieldnames(" + topic_name + ");";
        eval(eval_string_6);

        timestamp_sec_position = endsWith(fields, '__sec');
        timestamp_nsec_position = endsWith(fields, '__nanosec');

        if any(timestamp_sec_position) && any(timestamp_nsec_position)
            sec_fields = find(timestamp_sec_position);
            nsec_fields = find(timestamp_nsec_position);
            for j = 1:min(length(sec_fields), length(nsec_fields)) % It might associate the wrong sec-nsec if multiple fields have the same suffix
                field_name_sec = topic_name + ".(fields{sec_fields(j)})";
                eval("tmp_str = strrep(fields{sec_fields(j)}, 'sec', 'tot');");
                field_name_tot = topic_name + "." + tmp_str;
                eval(field_name_tot + " = zeros(size(" + field_name_sec + "));");
                eval(field_name_tot + " = cast(" + field_name_tot + ",'int64');");
                field_name_nsec = topic_name + ".(fields{nsec_fields(j)})";
                if any(eval(field_name_sec + "(1,:) ~= 0"))
                    eval_string_7 = "tmp_sec = " + field_name_sec + " - zero_timestamp_sec;";
                    eval_string_8 = "tmp_nsec = " + field_name_nsec + " - zero_timestamp_nsec;";
                    eval(eval_string_7);
                    eval(eval_string_8);
                    tmp_sec(tmp_nsec<0) = tmp_sec(tmp_nsec<0) - 1;
                    tmp_nsec(tmp_nsec<0) = tmp_nsec(tmp_nsec<0) + 1e9;
                    tmp_nsec(tmp_sec<0) = int64(0);
                    tmp_sec(tmp_sec<0) = int64(0);
                    eval(field_name_sec + " = double(tmp_sec);");
                    eval(field_name_nsec + " = double(tmp_nsec);");
                    eval(field_name_tot + " = double(tmp_nsec)*1e-9+double(tmp_sec);");
                end
            end
        end

        eval_string_9 = topic_name + ".(fields{1}) = double(" + topic_name + ".(fields{1}) - zero_bag_timestamp)*1e-9;";
        eval(eval_string_9);
    end

    %% Save all data in just 1 struct
    
    [~, output_filename, ~] = fileparts(sel_path{p});
    output_path = fullfile(sel_path{p}, output_filename + ".mat");
    fprintf("\nSaving data to: %s\n", output_path);

    for i = 1:length(topic_list)
        filename = topic_list(i);
        topic_name = sprintf("%s", erase(filename, ".csv"));

        eval_string_10 = "fields = fieldnames(" + topic_name + ");";
        eval(eval_string_10);

        for j = 1:length(fields)
            eval_string_11 = "log.(fields{j}) = " + topic_name + ".(fields{j});";
            eval(eval_string_11);
        end

    end
    
    try
        log = rmfield(log, {'Properties','Row','Variables'});
        save(output_path, 'log', '-v7.3');
    catch e
        warning("WARNING: Could not save files");
        warning("Error type:  " + e.message);
    end
        
    rmpath(sel_path{p});
    rmpath(bag_csv_path);
    clearvars -except sel_path
end


function [pathname] = uigetdir2(start_path, dialog_title)
    % Pick multiple directories and/or files

    import javax.swing.JFileChooser;

    if nargin == 0 || start_path == '' || start_path == 0 % Allow a null argument.
        start_path = pwd;
    end

    jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);

    jchooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
    if nargin > 1
        jchooser.setDialogTitle(dialog_title);
    end

    jchooser.setMultiSelectionEnabled(true);

    status = jchooser.showOpenDialog([]);

    if status == JFileChooser.APPROVE_OPTION
        jFile = jchooser.getSelectedFiles();
        pathname{size(jFile, 1)}=[];
        for i=1:size(jFile, 1)
            pathname{i} = char(jFile(i).getAbsolutePath);
        end

    elseif status == JFileChooser.CANCEL_OPTION
        pathname = [];
    else
        error('Error occured while picking file.');
    end
end


function out = importCsv(filename)

    dataLines = [3, Inf];
    
    fid = fopen(filename, 'r');
    fields_names = textscan(fid, '%[^\n]', 1);

    % Modify CSV names for easier data analysys and to replace too long names
    fields_names = split(fields_names{1}, ',');
    fields_names = strrep(fields_names, "longitudinal", "long");
    fields_names = strrep(fields_names, "polimove__", "");
    fields_names = strrep(fields_names, "estimation__vehicle_state__", "estimation__");
    fields_names = strrep(fields_names, "perception__radar__track_list__", "radar_track_list__");
    fields_names = strrep(fields_names, "perception__radar__targets_meas_list__", "radar_targets__");
    fields_names = strrep(fields_names, "perception__radar__targets_meas_list__", "radar_targets__");
    fields_names = strrep(fields_names, "ghostcar__", "gc__");
    % new perception topics
    fields_names = strrep(fields_names, "perception__lidar__clustering_detections__", "perception__lidar_cluster__");
    fields_names = strrep(fields_names, "perception__radar__clustering_detections__", "perception__radar_cluster__");
    fields_names = strrep(fields_names, "perception__lidar__pointpillars_detections__", "perception__lidar_pp__");
    fields_names = strrep(fields_names, "perception__camera__yolo_detections__", "perception__camera_yolo__");
    fields_names = strrep(fields_names, "perception__opponents__", "perception__opp__");
    fields_names = strrep(fields_names, "opponents_1_ekf_p_", "opponents_1_ekf_p");
    fields_names = strrep(fields_names, "opponents_2_ekf_p_", "opponents_2_ekf_p");
    fields_names = strrep(fields_names, "opponents_3_ekf_p_", "opponents_3_ekf_p");
    fields_names = strrep(fields_names, "opponents_4_ekf_p_", "opponents_4_ekf_p");
    fields_names = strrep(fields_names, "opponents_5_ekf_p_", "opponents_5_ekf_p");
    fields_names = strrep(fields_names, "opponents_6_ekf_p_", "opponents_6_ekf_p");
    fields_names = strrep(fields_names, "opponents_7_ekf_p_", "opponents_7_ekf_p");
    fields_names = strrep(fields_names, "opponents_8_ekf_p_", "opponents_8_ekf_p");
    fields_names = strrep(fields_names, "opponents_9_ekf_p_", "opponents_9_ekf_p");
    fields_names = strrep(fields_names, "opponents_10_ekf_p_", "opponents_10_ekf_p");
    fields_names = strip(fields_names);
    
    for i = 1:length(fields_names)
        if length(fields_names{i}) > 63
            %fprintf("Name: %s is too long - Truncated!\n", fields_names{i});
            fields_names{i} = fields_names{i}(1:63);
        end
    end
    fields_names = string(fields_names)';

    fields_types = textscan(fid, '%[^\n]', 1);
    fields_types = split(fields_types{1}, ',');
    fields_types = strip(fields_types);
    fields_types = strrep(fields_types, "int", "int64");
    fields_types = strrep(fields_types, "uint64", "int64");
    fields_types = strrep(fields_types, "float", "double");
    fields_types = strrep(fields_types, "bool", "logical");
    fields_types = strrep(fields_types, "str", "string");
    fields_types = string(fields_types)';
    fclose(fid);

    %% Set up the Import Options and import the data
    opts = detectImportOptions(filename, 'Delimiter',',', 'NumVariables', length(fields_names));
        
    % Specify column names and types
    opts.DataLines = dataLines;
    opts.VariableNames = fields_names;
    opts.SelectedVariableNames = fields_names;
    opts.VariableTypes = fields_types;

    % Import the data
    out = readtable(filename, opts);

end
