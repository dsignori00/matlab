function line = open_line(line)

    if ~isfield(line, 'closed')
        line.closed = line.x(1) == line.x(end) && line.y(1) == line.y(end);
    end

    if ~line.closed
        return;
    end

    line.x = line.x(1:end-1);
    line.y = line.y(1:end-1);

    if isfield(line, 's')
        line.s = line.s(1:end-1);
    end

    if isfield(line, 'psi')
        line.psi = line.psi(1:end-1);
    end

    if isfield(line, 'k')
        line.k = line.k(1:end-1);
    end

    if isfield(line, 'lat') && isfield(line, 'lon')
        line.lat = line.lat(1:end-1);
        line.lon = line.lon(1:end-1);
    end

    if isfield(line, 'n')
        line.n = line.n(1:end-1);
    end

    line.closed = false;

end

