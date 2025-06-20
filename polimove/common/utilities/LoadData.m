function [varargout] = load_data(log,rename_var,Ts,t_start,t_stop,low_pass_freq)

%% filter definition

s=tf('s');
low_pass_der_tc = 1/(s/2/pi/low_pass_freq + 1)^2;
low_pass_der_td = c2d(low_pass_der_tc,Ts,'Tustin');
low_pass_der_num = low_pass_der_td.Numerator{1};
low_pass_der_den = low_pass_der_td.Denominator{1};

%% load logged data

[~,~,rename_variable_cell] = xlsread(rename_var);

if t_start == -inf
    if isfield(log, 'vehicle_fbk__bag_timestamp')
        t_start=double(log.vehicle_fbk__bag_timestamp(1))+1;
    elseif isfield(log, 'vehicle_fbk_eva__bag_timestamp')
        t_start=double(log.vehicle_fbk_eva__bag_timestamp(1))+1;
    elseif isfield(log, 'estimation__bag_timestamp')
        t_start=double(log.estimation__bag_timestamp(1))+1;
    elseif isfield(log, 'control__long__command__bag_timestamp')
        t_start=double(log.control__long__command__bag_timestamp(1))+1;
    else
        error('Cannot find any topic to determine start of bag. Try specifying a t_stop time instad of using t_stop=inf.')
    end
end

if t_stop == inf
    if isfield(log, 'vehicle_fbk__bag_timestamp')
        t_stop=double(log.vehicle_fbk__bag_timestamp(end))-1;
    elseif isfield(log, 'vehicle_fbk_eva__bag_timestamp')
        t_stop=double(log.vehicle_fbk_eva__bag_timestamp(end))-1;
    elseif isfield(log, 'estimation__bag_timestamp')
        t_stop=double(log.estimation__bag_timestamp(end))-1;
    elseif isfield(log, 'control__long__command__bag_timestamp')
        t_stop=double(log.control__long__command__bag_timestamp(end))-1;
    else
        error('Cannot find any topic to determine end of bag. Try specifying a t_stop time instad of using t_stop=inf.')
    end
end

time=(t_start:Ts:t_stop)';


%% preprocessing

% 1. renaming, 2. resmplaing, 3. gain+offset correction

[n_row,~] = size(rename_variable_cell);

i_var = 1;
for i_var_list = 2:n_row
    time_zero=0;
    for j_var_list = 2:n_row
        try
            
            signal_time_name = rename_variable_cell{j_var_list,7};
            signal_time = log.(signal_time_name);
            
            
            if signal_time(1)>time_zero
                time_zero=signal_time(1);
            end
        end
        
    end
    
    
    signal_name_old = rename_variable_cell{i_var_list,1};
    signal_name_new = rename_variable_cell{i_var_list,2};
    gain = rename_variable_cell{i_var_list,3};
    offset = rename_variable_cell{i_var_list,4};
    signal_time_name = rename_variable_cell{i_var_list,7};
    
    try
        signal =double(log.(signal_name_old));
%         signal_time = double(log.(signal_time_name)-time_zero);
        signal_time = double(log.(signal_time_name));
        
        signal = gain*signal+offset;
        
        if strcmp(rename_variable_cell{i_var_list,6},'[rad]')
            signal=wrapToPi(signal);
            signal=unwrap(signal);
        end        
        
        dataset_out.(signal_name_new)= interp1(signal_time,signal,time,rename_variable_cell{i_var_list,10},nan);
%                 dataset_out.(signal_name_new)=fillmissing(dataset_out.(signal_name_new),'constant',0);
        
        if strcmp(rename_variable_cell{i_var_list,11},'ON')
             dataset_out.(signal_name_new)= filtfilt(low_pass_der_num,low_pass_der_den,fillmissing(dataset_out.(signal_name_new),'constant',0));       
        end
        
    catch e
        dataset_out.(signal_name_new)=nan(size(time));
        disp(['error:  ',signal_name_old, '     Exception:   ',e.identifier])
        
    end
    
    
    save_list{i_var,1} = signal_name_new;
    i_var = i_var+1;
    
    
    % clear signal_name_new signal_name_old signal gain offset signal_time_name
end

check_saved_all = setdiff(unique(rename_variable_cell(:,2)),save_list);

if not(isempty(check_saved_all))
    flag_message = 'unsaved variables';
else
    flag_message = 'OK';
end


% dataset_out.time=time-t_start;
dataset_out.time=time;

%dataset_out=fill_missing(dataset_out);

%%

varargout{1} = dataset_out;
varargout{2} = flag_message;


end

