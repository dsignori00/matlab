function [varargout] = load_data_pm(log,rename_var,Ts,t_start,t_stop)


%% load logged data 

        
[~,~,rename_variable_cell] = xlsread(rename_var);


if t_stop==inf
%     t_stop=double(log.vehicle_fbk__bag_timestamp(end)-log.vehicle_fbk__bag_timestamp(1))-1;
    t_stop=double(log.estimation__vehicle_state__bag_timestamp(end)-log.estimation__vehicle_state__bag_timestamp(1))-1;
    
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
        signal_time = double(log.(signal_time_name)-time_zero);
        
        [signal_time,ind,~] = unique(signal_time,'stable');
        signal=signal(ind);
        signal = gain*signal+offset;
        
        if strcmp(rename_variable_cell{i_var_list,6},'[rad]')
             signal=wrapToPi(signal);
             signal=unwrap(signal);
        end

        dataset_out.(signal_name_new)= interp1(signal_time,signal,time,rename_variable_cell{i_var_list,10});
        dataset_out.(signal_name_new)=fillmissing(dataset_out.(signal_name_new),'constant',0);
        
%         if strcmp(rename_variable_cell{i_var_list,6},'[rad]')
%              dataset_out.(signal_name_new)=wrapToPi(dataset_out.(signal_name_new));
%              dataset_out.(signal_name_new)=unwrap(dataset_out.(signal_name_new));
%         end
        
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


dataset_out.time=time-t_start;

%dataset_out=fill_missing(dataset_out);

%%

varargout{1} = dataset_out;
varargout{2} = flag_message;


end

