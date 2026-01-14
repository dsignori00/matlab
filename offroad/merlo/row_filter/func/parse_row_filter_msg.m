function row_filt_msg = parse_row_filter_msg(log)
%PARSELINEEQUATIONS Summary of this function goes here
%   Detailed explanation goes here
    row_filt_msg = struct();
    row_filt_msg.stamp = log.perception__row_filter__row_filter_msg.stamp;
    row_filt_msg.in_row = log.perception__row_filter__row_filter_msg.in_row;

    row_filt_msg.heading = log.perception__row_filter__row_filter_msg.heading;
    row_filt_msg.heading_ok = log.perception__row_filter__row_filter_msg.heading_ok;

    row_filt_msg.dist_left_row   = log.perception__row_filter__row_filter_msg.dist_left_row;
    row_filt_msg.dist_right_row   = log.perception__row_filter__row_filter_msg.dist_right_row;
    row_filt_msg.obstacle_in_row   = log.perception__row_filter__row_filter_msg.obstacle_in_row;
    
    row_filt_msg.dist_left_row(row_filt_msg.dist_left_row == -1) = nan;
    row_filt_msg.dist_right_row(row_filt_msg.dist_right_row == -1) = nan;
    row_filt_msg.dist_left_row(row_filt_msg.dist_left_row == 999) = nan;
    row_filt_msg.dist_right_row(row_filt_msg.dist_right_row == 999) = nan;

end

