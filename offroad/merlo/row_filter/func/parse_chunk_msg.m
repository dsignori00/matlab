function chunks = parse_chunk_msg(log, topic, name, enable_far_chunks)
%PARSE_LINE_EQUATIONS Parse line equations from log structure

    chunks = struct();
    chunks.num_chunks = log.(topic).num_chunks;

    % ---- Campi principali (dinamici) ----
    chunks.state                        = log.(topic).(sprintf('%s__state', name));
    chunks.forget_chunk_len_counter     = log.(topic).(sprintf('%s__forget_chunk_len_counter', name));
    chunks.end_row_detection_len        = log.(topic).(sprintf('%s__end_row_detection_len', name));
    chunks.start_pt = log.(topic).(sprintf('%s__start_pt', name));
    chunks.end_pt   = log.(topic).(sprintf('%s__end_pt', name));

    % ---- Rimuovi chunk in base a flag ----
    if(~enable_far_chunks)
        for i = 1:length(chunks.num_chunks)
            for idx =1:4:4
                chunks.state(i,idx)   = NaN;
                chunks.forget_chunk_len_counter(i,idx)  = NaN;
                chunks.end_row_detection_len(i,idx) = NaN;
            end
        end
    end
end