%% IN ROW DETECTION (visualize only if automatic inrow-det was enabled)

if (ismember(strategies, INROWDETSTR.AUTOMATIC))

    inrowdet_idx = true(size(bag1.perc_time));
    inrowdet_idx(bag1.log.perception__row_filter__debug__info.inrowdet_strategy ~= INROWDETSTR.AUTOMATIC) = false;
    
    figure("Name","InRowDet - Chunks");
    tiledlayout(6,2, "TileSpacing","compact")
    ax(f) = nexttile([2,2]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__end_row_detection_len(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__end_row_detection_len(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    ylabel("chunk length")
    legend show
    
    
    ax(f) = nexttile([2,2]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__density(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__density(inrowdet_idx,2), 'DisplayName',bag1.log_name +" R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("timestamp [s]")
    ylabel("density chunk ")
    legend show
    
    ax(f) = nexttile([2,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__state(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("timestamp [s]")
    ax(f-1).YTickLabel = {'forgot','not fitted','fitted', 'discarded'};
    title("state ")
    legend show
    
    ax(f) = nexttile([2,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__state(inrowdet_idx,2), 'DisplayName', bag1.log_name + " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("timestamp [s]")
    ax(f-1).YTickLabel = {'forgot','not fitted','fitted', 'discarded'};
    title("state ")
    legend show
end