function ego_index = compute_idx_sim(ego_x, ego_y, trajX, trajY, max_search_radius, jump_threshold)
% computeEgoClosestIndex - Calcola l'indice del punto più vicino sull'intero tracciato
% per ogni posizione dell'ego vehicle, con supporto a salti (teletrasporti).
%
% USO:
%   ego_index = computeEgoClosestIndex(ego_x, ego_y, trajX, trajY)
%   ego_index = computeEgoClosestIndex(..., max_search_radius, jump_threshold)
%
% INPUT:
%   ego_x            - vettore X della traiettoria del veicolo ego
%   ego_y            - vettore Y della traiettoria del veicolo ego
%   trajX            - vettore X del tracciato di riferimento
%   trajY            - vettore Y del tracciato di riferimento
%   max_search_radius (opzionale) - raggio locale per ricerca (default: 10)
%   jump_threshold     (opzionale) - soglia per salto libero [metri] (default: 25)
%
% OUTPUT:
%   ego_index - vettore con indici del punto più vicino sul tracciato

    if nargin < 5
        max_search_radius = 20;
    end
    if nargin < 6
        jump_threshold = 25;
    end

    jump_threshold_squared = jump_threshold^2;
    ego_index = NaN(size(ego_x));
    trajX = trajX(:);
    trajY = trajY(:);

    for i = 1:length(ego_x)
        if ~isnan(ego_x(i)) && ~isnan(ego_y(i))
            if i == 1 || isnan(ego_index(i-1))
                % Prima iterazione o reset: cerca su tutto il tracciato
                dx = trajX - ego_x(i);
                dy = trajY - ego_y(i);
                [~, ego_index(i)] = min(dx.^2 + dy.^2);
            else
                % Calcola distanza dal punto precedente
                prev_idx = ego_index(i-1);
                dx_prev = trajX(prev_idx) - ego_x(i);
                dy_prev = trajY(prev_idx) - ego_y(i);
                dist2 = dx_prev^2 + dy_prev^2;

                if dist2 < jump_threshold_squared
                    % Ricerca locale
                    idx_range = max(prev_idx - max_search_radius, 1):min(prev_idx + max_search_radius, length(trajX));
                    dx = trajX(idx_range) - ego_x(i);
                    dy = trajY(idx_range) - ego_y(i);
                    [~, local_min] = min(dx.^2 + dy.^2);
                    ego_index(i) = idx_range(local_min);
                else
                    % Salto globale (teletrasporto)
                    dx = trajX - ego_x(i);
                    dy = trajY - ego_y(i);
                    [~, ego_index(i)] = min(dx.^2 + dy.^2);
                end
            end
        end
    end
end
