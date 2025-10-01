function log_struct = VRXlog2struct(log_filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                         %
%         poliMove - IAC - VRXlog2struct                           %                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision: 2                                                             %
% Author: Alex Gimondi                                                %
% Date: 2020.09.01                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to convert a CSV / TXT exported from VRX to a struct
% Input: - 'log_filename' : complete path of the exported csv/txt file
%          !! .txt files must be compatible with a .csv format !!
% Output: - log_struct: struct which contains for each column of the
%           csv/txt file the related field (array of dimensions [Nsamples x 1] ) 

% detect import options from the file
imp_options = detectImportOptions(log_filename);
% .csv file loaded as table
T = readtable(log_filename,imp_options);
% create output struct
log_struct = table2struct(T,'ToScalar',true);
%rename variables
log_struct = VRXlog_struct_variables_rename(log_struct,'rename_variable');

end

