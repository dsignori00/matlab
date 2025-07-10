function progress_bar(percentDone,input_msg)  
if percentDone<0; percentDone=0; end
if percentDone>1; percentDone=1; end
msg = sprintf('%5.1f', percentDone*100); %Don't forget this semicolon
waitchar = repmat(sprintf('#'), 1, floor(percentDone*50));
spaces = repmat(sprintf(' '), 1, 50-floor(percentDone*50));
msg=strcat([input_msg,msg,'%%  [',waitchar,spaces,']\n']);
if percentDone==0
    reverseStr='';
else
    reverseStr = repmat(sprintf('\b'), 1, length(msg)-2);
end

fprintf([reverseStr, msg]);

end