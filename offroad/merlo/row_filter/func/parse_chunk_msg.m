function chunks = parse_chunk_msg(log, topic, name)
%PARSE_LINE_EQUATIONS Parse line equations from log structure

    chunks = struct();
    chunks.num_chunks = log.(topic).num_chunks;

    % ---- Campi principali (dinamici) ----
    chunks.state                        = log.(topic).(sprintf('%s__state', name));
    chunks.density                      = log.(topic).(sprintf('%s__density', name));
    chunks.forget_chunk_len_counter     = log.(topic).(sprintf('%s__forget_chunk_len_counter', name));
    chunks.end_row_detection_len        = log.(topic).(sprintf('%s__end_row_detection_len', name));

    % ---- Pulizia colonne oltre num_chunks ----
    n_cols = size(chunks.state, 2);
    for i = 1:length(chunks.num_chunks)
        idx = chunks.num_chunks(i);
        if idx < n_cols
            cols = idx+1:n_cols;
            chunks.state(i,cols)   = NaN;
            chunks.density(i,cols)   = NaN;
            chunks.forget_chunk_len_counter(i,cols)  = NaN;
            chunks.end_row_detection_len(i,cols) = NaN;
        end
    end
end