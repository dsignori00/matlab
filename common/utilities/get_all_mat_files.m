function file_names_list = get_all_mat_files(dir_path)

    dir_output = dir(fullfile(dir_path, '*.mat'));

    N_strings = length(dir_output);
    file_names_list = cell(N_strings, 1);

    for i=1:N_strings
        
        file_names_list{i} = string(dir_output(i).name);

    end

end

