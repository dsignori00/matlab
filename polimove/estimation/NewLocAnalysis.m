clearvars -except log log_ref

use_ref = false;

% load track lines
% load('../../05_Scripts/Yas_Marina_DB/databases/Yas_Marina_apex_v5_new_pit/trajDatabase.mat');
load('../../../../iac/09_Databases/04_Databases/BALOCCO/BALOCCO_apex_v0/trajDatabase.mat');

% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

% load log ref
if(use_ref)
    if (~exist('log_ref','var'))
        [file,path] = uigetfile('*.mat','Load log_ref');    
        tmp = load(fullfile(path,file));
        log_ref = tmp.log;
        clearvars tmp;
    end
else
    log_ref = [];
end

% DateTime = datetime(log.time_offset_nsec,'ConvertFrom','epochtime','TicksPerSecond',1e9,'Format','dd-MMM-yyyy HH:mm:ss');

%% logical vars coversion
% fields=fieldnames(log.estimation);
% for i=1:length(fields)
%     if isa(log.estimation.(fields{i}),'uint8')
%         log.estimation.(fields{i})=logical(log.estimation.(fields{i}));
%     end
% end

%%
% log_ref = 0;
plot_data(log,log_ref, trajDatabase);


