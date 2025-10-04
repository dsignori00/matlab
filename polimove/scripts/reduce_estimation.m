clc; clearvars -except log file

if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

out.stamp = log.estimation.stamp__tot;
out.x_cog = log.estimation.x_cog;
out.y_cog = log.estimation.y_cog;
out.vx = log.estimation.vx;
out.heading = log.estimation.heading;

parts = strsplit(file,'_');
T = struct2table(out);
writetable(T, parts{1} + "_polimove_loc.csv", 'Delimiter', ',', 'WriteRowNames',true);
