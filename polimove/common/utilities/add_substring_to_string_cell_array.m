function new_string_cell_array = add_substring_to_string_cell_array(single_substring, string_cell_array)

    N_strings = length(string_cell_array);

    new_string_cell_array = cell(N_strings, 1);

    for i=1:N_strings
        new_string_cell_array{i} = single_substring + string_cell_array{i};
    end

end

