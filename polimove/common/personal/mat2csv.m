clearvars -except output_path log 

mats_path = "/home/dano00/Documents/PoliMOVE/04_Bags/";

% load ego log
if (~exist('log','var'))
    [file,path] = uigetfile(fullfile(mats_path,'*.mat'),'Select file to convert');
    tmp = load(fullfile(path,file));
    log = tmp.log;
    clearvars tmp;
end

fields = fieldnames(log);
lengths = cellfun(@(f) length(log.(f)), fields);
if ~all(lengths == lengths(1))
    error('Tutti i campi della struct devono avere la stessa lunghezza.');
end

tabella = struct2table(log);
if (~exist('output_file','var'))
    output_file = fullfile(path,file);
    output_file = strrep(output_file,'.mat','.csv');
end
writetable(tabella,output_file,'WriteVariableNames', true);

