function line_eq = parse_line_equations(log, topic, name)
%PARSE_LINE_EQUATIONS Parse line equations from log structure

    line_eq = struct();
    line_eq.num_lines = log.(topic).(sprintf('num_%s', name));

    % ---- Campi principali (dinamici) ----
    line_eq.coeff = log.(topic).(sprintf('%s__coeff', name));
    line_eq.p1    = log.(topic).(sprintf('%s__p1', name));
    line_eq.p2    = log.(topic).(sprintf('%s__p2', name));
    line_eq.rho   = log.(topic).(sprintf('%s__rho', name));
    line_eq.form  = double(log.(topic).(sprintf('%s__form', name)));
    line_eq.associated_line = log.(topic).(sprintf('%s__associated_line', name));
    line_eq.associated_angle = log.(topic).(sprintf('%s__associated_angle', name));
    line_eq.start_pt = log.(topic).(sprintf('%s__start_pt', name));
    line_eq.end_pt   = log.(topic).(sprintf('%s__end_pt', name));

    % ---- Pulizia colonne oltre num_lines o per linee non inizializzate----
    n_cols = size(line_eq.p1, 2);
    for i = 1:length(line_eq.num_lines)
        idx = line_eq.num_lines(i);
        form = line_eq.form(i);
        if idx < n_cols || form == -1
            cols = idx+1:n_cols;
            line_eq.p1(i,cols)   = NaN;
            line_eq.p2(i,cols)   = NaN;
            line_eq.rho(i,cols)  = NaN;
            line_eq.form(i,cols) = NaN;
            if isfield(line_eq,'associated_line')
                line_eq.associated_line(i,cols) = NaN;
            end
            line_eq.coeff(i,cols,:)    = NaN;
            line_eq.start_pt(i,cols,:) = NaN;
            line_eq.end_pt(i,cols,:)   = NaN;
        end
    end
end

