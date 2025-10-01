function [idx_start, idx_end] = get_lat_delay_idx(TURN_NAME)


    switch TURN_NAME

        case "PRIMA_VARIANTE"
            idx_start = 1100;
            idx_end = 1500;
        case "SECONDA_VARIANTE"
            idx_start = 3600;
            idx_end = 3900;
        case "LESMO_1"
            idx_start = 4250;
            idx_end = 4800;
        case "LESMO_2"
            idx_start = 5000;
            idx_end = 5300;
        case "ASCARI"
            idx_start = 7200;
            idx_end = 7900;
        case "PARABOLICA"
            idx_start = 9400;
            idx_end = 10200;
        otherwise
            error("Invalid turn name");

    end

end

