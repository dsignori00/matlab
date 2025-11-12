clearvars 
close all
clc

%% Paths

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
addpath("../utils/")
normal_path = "../../bags";

%% Execute

if (~exist('log','var'))
    [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log');
    load(fullfile(path,file));
end

log = normalize_stamps(log);

try
    output_path = fullfile(path,file);
    fprintf("Saving processed data to: %s\n", output_path);
    save(output_path, 'log', '-v7.3');
catch e
    warning("WARNING: Could not save processed data");
    warning("Error type:  " + e.message);
end

