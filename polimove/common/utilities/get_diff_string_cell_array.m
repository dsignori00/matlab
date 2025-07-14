function diff_list = get_diff_string_cell_array(list_1, list_2)

    N_list_1 = length(list_1);
    N_list_2 = length(list_2);

    idx_vec = true(N_list_1, 1);

    for i=1:N_list_1

        curr_string = list_1{i};

        for j=1:N_list_2

            if strcmp(curr_string, list_2{j})
                idx_vec(i) = false;
                break;
            end

        end

    end

    diff_list = list_1(idx_vec);

end

