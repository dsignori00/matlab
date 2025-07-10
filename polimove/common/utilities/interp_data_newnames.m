function out = interp_data_newnames(log, topic_label,t_start,t_stop,topic_sel,interp_method)
%interp_tp_data interpolate Tactical Planner data on a single time axis

if (nargin < 2)
  topic_label = "estimation";
end
if (nargin < 3)
  t_start = 0.0;
end
if (nargin < 4)
  t_stop = inf;
end
if (nargin < 5)
  topic_sel = {'\w*'};
end
if (nargin < 6)
  interp_method = 'previous';
end


%% PREPROCESS
out.time_offset_nsec = log.time_offset_nsec;
log = rmfield(log, 'time_offset_nsec');

%% GET TOPICS
timestamp_string = ".bag_stamp";
header_string = "__header__stamp__tot";
exclude_string = [...
  "stamp__tot";
  "stamp__nanosec";
  "stamp__sec";
  "metrics";
  "frame_id";
  "header_frame_id"];
fields_raw = extractAllFields(log);
% Select fields
fields = {};
for i = 1:length(fields_raw)
  f = fields_raw{i};
  if cell2mat(regexp(f, topic_sel, 'once'))
    fields{end+1,1} = f;
  end
end

topic_names = [];
timestamp_names = [];
time = nan;

for i = 1:length(fields)
  f = string(fields{i});
  if strcmp(f, "vehicle_fbk_eva__wheel_speed_fbk_stamp__tot")
      disp("here")
  end
  ends_with_stamp = endsWith(f, timestamp_string);
  ends_with_header = endsWith(f, header_string);
  if ends_with_stamp || ends_with_header
    if ends_with_header
      pattern_string = header_string;
    else
      pattern_string = timestamp_string;
    end
    topic_names = [topic_names;extractBefore(f, pattern_string)];
    timestamp_names = [timestamp_names;f];
    if contains(f, topic_label)
      time = getNestedField(log,f);
    end
%   elseif any(contains(f, exclude_string)) ||sum(isstrprop(f,'upper')) > 3 % discard enum labels
    elseif any(contains(f, exclude_string)) % keep enum constants
        log = removeField(log,f);
  end
  
end

if isnan(time)
  error("%s: topic not found. Provide a valid topic to select time axis",f);
end

%% CUT TIME VECTOR

t_start = max(time(1), t_start);
t_stop = min(time(end), t_stop);
time = time(time>=t_start & time<t_stop);


%% SCAN AND INTERPOLATE
out.time = time;
fields_raw = extractAllFields(log);
% Select fields
fields = {};
for i = 1:length(fields_raw)
  f = fields_raw{i};
  if cell2mat(regexp(f, topic_sel, 'once'))
    fields{end+1,1} = f;
  end
end

for i = 1:length(fields)
  f = string(fields{i});
  topic_idx = find_pattern(f, topic_names);
  ends_with_stamp = endsWith(f, timestamp_string);
  ends_with_header = endsWith(f, header_string);
  if ~(ends_with_stamp || ends_with_header)
    try
      timestamp_in = getNestedField(log,(timestamp_names{topic_idx}));
      % Add enum constant directly to out (skip interpolation)
      val_in = getNestedField(log,f);
      if length(val_in) == 1
        out = setNestedField(out,f,val_in);
        continue;
      end
      [~,idx_unique,~] = unique(timestamp_in);
      value = interp1(timestamp_in(idx_unique),double(val_in(idx_unique,:)),time, interp_method, nan);
      % Logical values
      if islogical(val_in)
          value = logical(value(~isnan(value)));
      end
      out = setNestedField(out,f,value);
    catch e
      warning("Field %s discarded", f);
      warning("Id: %s. Message: %s", e.identifier, e.message);
    end
  end
end

end

function idx = find_pattern(str, patterns)
idx = nan;
score = inf;
for i = 1:length(patterns)
  if startsWith(str,patterns(i))
    score_tmp = strlength(erase(str,patterns(i)));
    if (score_tmp < score)
      score = score_tmp;
      idx = i;
    end
  end
end
end

