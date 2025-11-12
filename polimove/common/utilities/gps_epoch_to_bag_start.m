clearvars 
close all
clc

%% Paths

addpath("../../01_Tools/00_GlobalFunctions/personal/")
addpath("../../01_Tools/00_GlobalFunctions/utilities/")
addpath("../../01_Tools/00_GlobalFunctions/constants/")
addpath("../../01_Tools/00_GlobalFunctions/plot/")
normal_path = "/home/daniele/adehome_humble/code/bags";

%% Execute

if (~exist('log','var'))
    [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log');
    load(fullfile(path,file));
end

log = normalizeStamps(log);

try
    output_path = fullfile(path,file);
    fprintf("Saving processed data to: %s\n", output_path);
    save(output_path, 'log', '-v7.3');
catch e
    warning("WARNING: Could not save processed data");
    warning("Error type:  " + e.message);
end

