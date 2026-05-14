function out = load_row_filter_data(in)
    %LOAD_ROW_FILTER_DATA Load row filter data from log structure
    out.log_name = "";
    out.lines = parse_line_equations(in, 'perception__row_filter__line_equations', 'lines');
    out.lines.stamp = in.perception__row_filter__line_equations.stamp;
    out.state = parse_row_filter_msg(in);
    out.debug = parse_debug_msg(in);
    out.measures = parse_line_equations(in,'perception__row_filter__debug__equation_meas', 'lines'); 
    out.measures.stamp = in.perception__row_filter__debug__equation_meas.stamp;
    out.ego = parse_vehicle_state(in);
end