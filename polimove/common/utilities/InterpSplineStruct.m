function data_out=interp_spline_struct(data,Ts)


fields = fieldnames(data);                                                
data_out.time=data.time;

for i = 1:length(fields)
    if fields{i}~="time" 
    aux=double(data.(fields{i}));
    data_out.(fields{i})= interp1(data.time,aux,data.time,'spline'); 
    end
end

end

