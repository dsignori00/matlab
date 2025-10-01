function data_out=fill_missing(data)

fields = fieldnames(data);                                                
data_out.time=data.time;

for i = 1:length(fields)
    if fields{i}~="time" 
    aux=double(data.(fields{i}));
    data_out.(fields{i})= fillmissing(aux,'constant',0);
    end
end

end

