function line = CloseLine(line)

    if ~isfield(line, 'closed')
        line.closed = line.x(1) == line.x(end) && line.y(1) == line.y(end);
    end

    if line.closed
        return;
    end

    line.x(end+1) = line.x(1);
    line.y(end+1) = line.y(1);

    if isfield(line, 'psi')
        line.psi(end+1) = line.psi(1);
        line.psi = wrapToPi(line.psi);
    end

    if isfield(line, 'k')
        line.k(end+1) = line.k(1);
    end

    if isfield(line, 's')
        line.s(end+1) = line.s(end) + line.s(2);
    end

    if isfield(line, 'lat') && isfield(line, 'lon')
        line.lat(end+1) = line.lat(1);
        line.lon(end+1) = line.lon(1);
    end

    line.closed = true;

end

