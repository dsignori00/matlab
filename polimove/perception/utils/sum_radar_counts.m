function rad = sum_radar_counts(rad, num_radars)
%SUMRADARCOUNTS Sostituisce i count di ciascun radar con la somma totale
%   rad = sumRadarCounts(rad, num_radars)
%
%   INPUT:
%     rad         - struttura con campi:
%                       .count       vettore del numero di misure
%                       .sens_stamp  vettore dei timestamp radar
%     num_radars  - numero totale di radar (es. 4)
%
%   OUTPUT:
%     rad         - stessa struttura, ma con .count modificato:
%                   in ogni iterazione i valori di count sono sostituiti
%                   dalla somma totale delle misure trovate in quell’iterazione.
%
%   Nota:
%     L'ultima iterazione può contenere meno di num_radars radar.

    if nargin < 2
        num_radars = 4; % valore predefinito
    end

    n = length(rad.count);
    num_iter = ceil(n / num_radars);

    new_count = rad.count; % inizializza

    for i = 1:num_iter
        % Indici di questa iterazione
        idx_start = (i-1)*num_radars + 1;
        idx_end = min(i*num_radars, n);

        % Misure di questa iterazione
        this_iter_counts = rad.count(idx_start:idx_end);

        % Somma totale
        total_count = sum(this_iter_counts);

        % Sostituisci i valori
        new_count(idx_start:idx_end) = total_count;
    end

    % Aggiorna la struttura
    rad.count = new_count;
end
