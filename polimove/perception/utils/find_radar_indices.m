function indices = find_radar_indices(log)
% findRadarIndicesVector - Restituisce un vettore degli indici dei nodi radar.
%
% USO:
%   indices = findRadarIndicesVector(inputStr)
%
% INPUT:
%   inputStr : stringa contenente tutti i nomi dei nodi (separati da spazi)
%
% OUTPUT:
%   indices : vettore con gli indici dei nodi radar nello stesso ordine dei targets

    % Dividi in celle
    inputStr = log.liveliness__state.nodes_states__node_name(1,:);
    nodes = strsplit(inputStr);
    
    % Rimuovi celle vuote
    nodes = nodes(~cellfun('isempty', nodes));
    
    % Nodi radar da cercare
    targets = {'radar_front', 'radar_front/udp_pkgs', ...
               'radar_right', 'radar_right/udp_pkgs', ...
               'radar_left', 'radar_left/udp_pkgs', ...
               'radar_back', 'radar_back/udp_pkgs'};
    
    % Trova gli indici
    indices = cellfun(@(t) find(strcmp(nodes, t), 1, 'first'), targets);
end

