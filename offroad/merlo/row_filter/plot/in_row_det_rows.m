%% IN ROW DET CHUNKS (visualize only if automatic inrow-det was enabled)
if (ismember(strategies,INROWDETSTR.AUTOMATIC))
    figure("Name","InRowDet - Closest Rows");
    tiledlayout(3,2, "TileSpacing","compact")
    ax(f) = nexttile([1,2]); f=f+1;
    grid on; hold on;
    x_length(:,1) = abs(bag1.log.perception__row_filter__debug__info.closest_lines__x_min(inrowdet_idx,1) - bag1.log.perception__row_filter__debug__info.closest_lines__x_max(inrowdet_idx,1)); 
    x_length(:,2) = abs(bag1.log.perception__row_filter__debug__info.closest_lines__x_min(inrowdet_idx,2) - bag1.log.perception__row_filter__debug__info.closest_lines__x_max(inrowdet_idx,2)); 
    plot(bag1.perc_time(inrowdet_idx), x_length(:,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), x_length(:,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("x length")
    legend show
    
    ax(f) = nexttile([1,2]); f=f+1;
    grid on; hold on;
    y_length(:, 1) = abs(bag1.log.perception__row_filter__debug__info.closest_lines__y_min(inrowdet_idx,1) - bag1.log.perception__row_filter__debug__info.closest_lines__y_max(inrowdet_idx,1)); 
    y_length(:, 2) = abs(bag1.log.perception__row_filter__debug__info.closest_lines__y_min(inrowdet_idx,2) - bag1.log.perception__row_filter__debug__info.closest_lines__y_max(inrowdet_idx,2)); 
    plot(bag1.perc_time(inrowdet_idx), y_length(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), y_length(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("y length")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_lines__p1(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_lines__p1(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("m")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_lines__p2(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_lines__p2(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("q")
    legend show
end