function out = parse_debug_msg(log)
%PARSE_LINE_EQUATIONS Parse line equations from log structure
    out.stamp = log.perception__row_filter__debug__info.stamp;
    out.in_row_det.in_row_det_strategy = log.perception__row_filter__debug__info.inrowdet_strategy;
    out.in_row_det.out_row_fit_strategy = log.perception__row_filter__debug__info.outrowfit_strategy;
    out.in_row_det.automatic_in_row = log.perception__row_filter__debug__info.automatic_in_row;
    out.in_row_det.trajectory_in_row = log.perception__row_filter__debug__info.trajectory_in_row;
    out.in_row_det.joy_in_row = log.perception__row_filter__debug__info.joy_in_row;
    out.closest_lines = parse_line_equations(log, 'perception__row_filter__debug__info', 'closest_lines');
    out.chunks.enable_far_chunks = log.perception__row_filter__debug__info.enable_far_chunks;
    out.chunks = parse_chunk_msg(log, 'perception__row_filter__debug__info', 'chunks',out.chunks.enable_far_chunks);
    out.chunks.angle_max = log.perception__row_filter__debug__info.angle_max;
    out.chunks.end_row_threshold = log.perception__row_filter__debug__info.end_row_threshold;
    out.chunks.forget_chunk_len_trigger = log.perception__row_filter__debug__info.forget_chunk_len_trigger;
    out.chunks.rho_thr = log.perception__row_filter__debug__info.rho_thr;
    out.chunks.rho_thr_far = log.perception__row_filter__debug__info.rho_thr_far;
    out.line.measures = log.perception__row_filter__debug__info.line_measures;
    out.line.tracks = log.perception__row_filter__debug__info.line_tracks;
    out.rows_angle.map = log.perception__row_filter__debug__info.rows_angle_map;
    out.rows_angle.cog = log.perception__row_filter__debug__info.rows_angle_cog;
    out.rows_angle.estimated = log.perception__row_filter__debug__info.rows_angle_estimated;
    out.rows_angle.covariance = log.perception__row_filter__debug__info.rows_angle_covariance;

end