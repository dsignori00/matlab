function color = get_color(u, co)
if nargin < 2
    co = get(0,'defaultAxesColorOrder');
end
if isa(u, 'numeric')
    if u >= length(co)
        u = mod(u,length(co))+1;
    end
    color = co(u,:);
else
    switch u
        case {'blue', 'b'}
            color = co(1,:);
        case {'orange', 'o'}
            color = co(2,:);
        case {'yellow', 'y'}
            color = co(3,:);
        case {'violet', 'v'}
            color = co(4,:);
        case {'green', 'g'}
            color = co(5,:);
        case {'light blue', 'sky', 'lb'}
            color = co(6,:);
        case {'maroon', 'm'}
            color = co(7,:);
        case {'gray'}
            color = [0.7 0.7 0.7];
        case {'black', 'k'}
            color = [0 0 0];
        case {'light green', 'lg'}
            color = [.39 .83 .07];
        case {'light orange', 'lo'}
            color = [1 .41 .16];
    end
end
end