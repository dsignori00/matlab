function [idx, opp_idx] = find_closest_stamp(timestamp, ego_timestamp)
    % Preallocazione dei risultati
    idx = zeros(length(timestamp), 1);
    opp_idx = zeros(length(timestamp), 1);
    % Itera su ogni elemento di timestamp, calcolando le differenze localmente
    for i = 1:length(timestamp)
        % Calcola le differenze solo per l'elemento corrente
        diff = abs(ego_timestamp - timestamp(i));
        
        % Trova il minimo e l'indice corrispondente
        [min_diff, closest_idx] = min(diff);

        % Applica la soglia
        if min_diff < 1e9
            idx(i) = closest_idx;
            opp_idx(i) = i;    
        end
    end
    idx = idx(idx~=0);
    opp_idx = opp_idx(opp_idx~=0);
end