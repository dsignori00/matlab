function [dataset_out] = load_data_v2(log,Ts,t_start,t_stop,low_pass_freq)

%% filter definition

s=tf('s');
low_pass_der_tc = 1/(s/2/pi/low_pass_freq + 1)^2;
low_pass_der_td = c2d(low_pass_der_tc,Ts,'Tustin');
low_pass_der_num = low_pass_der_td.Numerator{1};
low_pass_der_den = low_pass_der_td.Denominator{1};

%% load logged data

fields = extractAllFields(log);

if t_start == -inf
    if any(strcmp(fields, 'vehicle_fbk.bag_stamp'))
        t_start=double(log.vehicle_fbk.bag_stamp(1))+1;
    elseif any(strcmp(fields, 'vehicle_fbk_eva.bag_stamp'))
        t_start=double(log.vehicle_fbk_eva.bag_stamp(1))+1;
    elseif any(strcmp(fields, 'estimation.bag_stamp'))
        t_start=double(log.estimation.bag_stamp(1))+1;
    elseif any(strcmp(fields, 'control__long__command.bag_stamp'))
        t_start=double(log.control__long__command.bag_stamp(1))+1;
    else
        error('Cannot find any topic to determine start of bag. Try specifying a t_stop time instad of using t_stop=inf.')
    end
end

if t_stop == inf
    if any(strcmp(fields, 'vehicle_fbk.bag_stamp'))
        t_stop=double(log.vehicle_fbk.bag_stamp(end))-1;
    elseif any(strcmp(fields, 'vehicle_fbk_eva.bag_stamp'))
        t_stop=double(log.vehicle_fbk_eva.bag_stamp(end))-1;
    elseif any(strcmp(fields, 'estimation.bag_stamp'))
        t_stop=double(log.estimation.bag_stamp(end))-1;
    elseif any(strcmp(fields, 'control__long__command.bag_stamp'))
        t_stop=double(log.control__long__command.bag_stamp(end))-1;
    else
        error('Cannot find any topic to determine end of bag. Try specifying a t_stop time instad of using t_stop=inf.')
    end
end

time=(t_start:Ts:t_stop)';


%% Resample data
removed_fields = {
    'frame_id';
    'header__frame_id';
    'header__stamp__tot';
    'time_offset_nsec';
    'perception';
    'low_level';
    'base_station';
    'commands__controlled_shutdown';
    'commands__coordinated_stop';
    'commands__emergency_shutdown';
    'competitors_list';
    'decision_maker';
    'diagnostics__ncu';
    'estimation__lidar_localization';
    'loc_node__debug';
    'perception';
    'tactical_planner__learning_opp_limits';
    'telemetry__high';
    'telemetry__low';
    'lidar_localization';
};


for i = 1:length(fields)

    substrings  = strsplit(fields{i}, '.');
    topic_name  = substrings{1};
    if strcmp(topic_name, 'time_offset_nsec')
        continue;

    else
        signal_name = substrings{2};
        if any(contains(signal_name, removed_fields)) || any(contains(topic_name, removed_fields))
            display(['Skipped topic: ', fields{i}])
            continue;
        end
        try
%             display(['Processing message ', fields{i}])
            dataset_out.(topic_name).(signal_name) = interp1(log.(topic_name).bag_stamp, log.(topic_name).(signal_name), time, 'linear');
            dataset_out.(topic_name).(signal_name) = filtfilt(low_pass_der_num,low_pass_der_den,...
            fillmissing(dataset_out.(topic_name).(signal_name),'constant',0));
        catch
            if (isa(log.(topic_name).(signal_name), 'single') || ...
               isa(log.(topic_name).(signal_name), 'int64')  || ...
               isa(log.(topic_name).(signal_name), 'int16')  || ...
               isa(log.(topic_name).(signal_name), 'uint16') || ...
               isa(log.(topic_name).(signal_name), 'int8')  || ...
               isa(log.(topic_name).(signal_name), 'uint8')) && length(log.(topic_name).(signal_name))>1
                % No filtering if single value. Do not change data type
                try
                    dataset_out.(topic_name).(signal_name) = interp1(log.(topic_name).bag_stamp, double(log.(topic_name).(signal_name)), time, 'linear');
                catch
                    display(['Error: length mismatch for field ', fields{i}])
                end
            elseif islogical(log.(topic_name).(signal_name))
                % No filering for logicals. Convert to double and interpolate.
                try
                    dataset_out.(topic_name).(signal_name) = interp1(log.(topic_name).bag_stamp, double(log.(topic_name).(signal_name)), time, 'linear');
                catch
                    display(['Error: length mismatch for field ', fields{i}])
                end
            elseif length(log.(topic_name).(signal_name)) == 1
                dataset_out.(topic_name).(signal_name) = log.(topic_name).(signal_name);
            else
                display(['Error: failed to process message ', fields{i}])
            end
        end
    end

end

dataset_out.time=time;

end

