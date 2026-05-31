function timeStr = sec2laptime(timeSec)
% sec2minsecms Convert seconds to string in min:sec:ms format
%   timeStr = sec2minsecms(timeSec)
%   Input:
%     timeSec - scalar or vector of times in seconds
%   Output:
%     timeStr - string array with format "mm:ss:ms"

    timeStr = strings(size(timeSec));  % Preallocate output

    for i = 1:numel(timeSec)
        mins = floor(timeSec(i) / 60);
        secs = floor(mod(timeSec(i), 60));
        ms   = round(mod(timeSec(i), 1) * 1000);
        timeStr(i) = sprintf('%02d:%02d:%03d', mins, secs, ms);
    end
end
