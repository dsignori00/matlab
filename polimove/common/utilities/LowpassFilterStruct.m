function data_out=lowpass_filter_struct(data,fcutoff,Ts)

%low pass filter definition

s=tf('s');
low_pass_der_tc = 1/(s/2/pi/fcutoff + 1)^2;
low_pass_der_td = c2d(low_pass_der_tc,Ts,'Tustin');
low_pass_der_num = low_pass_der_td.Numerator{1};
low_pass_der_den = low_pass_der_td.Denominator{1};

fields = fieldnames(data);                                                
data_out=data;

for i = 1:length(fields)
    if fields{i}~="time" && not(contains(fields{i},'_interp'))
    aux=double(data.(fields{i}));
    data_out.(fields{i})= filtfilt(low_pass_der_num,low_pass_der_den,fillmissing(aux,'constant',0));
    end
end

end

