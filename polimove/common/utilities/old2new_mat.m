close all
clearvars
clc

% load ego log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load mat');
    tmp = load(fullfile(path,file));
    log = tmp.log;
    clearvars tmp;
end

log = old2new(log);

output_path = fullfile(path, file);
fprintf("\nSaving data to: %s\n", output_path);

try
    save(output_path, 'log', '-v7.3');
catch e
    warning("WARNING: Could not save files");
    warning("Error type:  " + e.message);
end



%%  FUNCTIONS


function log_new = old2new(log_old)

% get topic names
log_old = orderfields(log_old);
fields=fieldnames(log_old);
log_new = struct();

for i=1:length(fields)
    underscores_pos = strfind(fields(i),'__bag_timestamp');
    if(isempty(underscores_pos{1}))
        continue;
    end
    current_topic = fields{i}(1:underscores_pos{1}(1)-1);

    if ~isfield(log_new, current_topic)
            log_new.(current_topic) = struct();
    end
end

% fill topics
topic_list=fieldnames(log_new);
for i=1:length(topic_list)
    for j=1:length(fields)
        topic_name_pos = strfind(fields(j),topic_list(i));
        if(~isempty(topic_name_pos{1}) && topic_name_pos{1}(1)==1 && fields{j}(length(topic_list{i})+1)=='_')
            current_field = fields{j}(length(topic_list{i})+1+2:end);
            if strcmp(current_field,'bag_timestamp')
                current_field = 'bag_stamp';
            end
            log_new.(string(topic_list(i))).(string(current_field)) = eval(strcat('log_old.',string(fields(j))));
        end
    end
end

% add t0
log_new.('time_offset_nsec') = log_old.time_offset_nsec;
% Reorder fields
log_new = orderfields(log_new);
end