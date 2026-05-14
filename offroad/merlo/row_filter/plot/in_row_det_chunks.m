%% IN ROW DETECTION (visualize only if automatic inrow-det was enabled)

if (ismember(strategies, INROWDETSTR.AUTOMATIC))

    inrowdet_idx = true(size(bag1.debug.stamp));
    inrowdet_idx(bag1.debug.in_row_det.in_row_det_strategy ~= INROWDETSTR.AUTOMATIC) = false;
    
    figure("Name","InRowDet - Chunks", 'NumberTitle','off');
    tiledlayout(6,2, "TileSpacing","compact")
    ax(f) = nexttile([2,2]); f=f+1;
    grid on; hold on;
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.end_row_detection_len(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " L");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.end_row_detection_len(inrowdet_idx,3), 'DisplayName', bag1.log_name + " R");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.end_row_detection_len(inrowdet_idx,1), 'DisplayName', bag1.log_name + " LF",'LineStyle','--','LineWidth',0.3);
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.end_row_detection_len(inrowdet_idx,4), 'DisplayName',bag1.log_name+  " RF",'LineStyle','--','LineWidth',0.3);
    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.end_row_detection_len(inrowdet_idx,2), 'DisplayName',bag2.log_name+  " L");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.end_row_detection_len(inrowdet_idx,3), 'DisplayName', bag2.log_name + " R");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.end_row_detection_len(inrowdet_idx,1), 'DisplayName', bag2.log_name + " LF",'LineStyle','--','LineWidth',0.3);
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.end_row_detection_len(inrowdet_idx,4), 'DisplayName',bag2.log_name+  " RF",'LineStyle','--','LineWidth',0.3);
    end
    if size(bag1.debug.stamp) == size(bag1.state.stamp)
        plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    end
    ylabel("chunk length")
    legend show
    
    
    ax(f) = nexttile([2,2]); f=f+1;
    grid on; hold on;
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.forget_chunk_len_counter(inrowdet_idx,2), 'DisplayName',bag1.log_name +" L");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.forget_chunk_len_counter(inrowdet_idx,3), 'DisplayName', bag1.log_name + " R");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.forget_chunk_len_counter(inrowdet_idx,1), 'DisplayName', bag1.log_name + " LF",'LineStyle','--','LineWidth',0.3);
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.forget_chunk_len_counter(inrowdet_idx,4), 'DisplayName',bag1.log_name +" RF",'LineStyle','--','LineWidth',0.3);
    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.forget_chunk_len_counter(inrowdet_idx,2), 'DisplayName',bag2.log_name+  " L");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.forget_chunk_len_counter(inrowdet_idx,3), 'DisplayName', bag2.log_name + " R");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.forget_chunk_len_counter(inrowdet_idx,1), 'DisplayName', bag2.log_name + " LF",'LineStyle','--','LineWidth',0.3);
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.forget_chunk_len_counter(inrowdet_idx,4), 'DisplayName',bag2.log_name+  " RF",'LineStyle','--','LineWidth',0.3);
    
    end
    if size(bag1.debug.stamp) == size(bag1.state.stamp)
        plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    end
    ylabel("forget counter [-]")
    legend show
    
    ax(f) = nexttile([2,1]); f=f+1;
    grid on; hold on; ylim(ax(f-1), [-1.5 2.5])
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.state(inrowdet_idx,2),'Color',colors.matlab{1}, 'DisplayName', bag1.log_name + " L");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.state(inrowdet_idx,1),'Color',colors.matlab{3}, 'DisplayName', bag1.log_name + " LF",'LineStyle','--','LineWidth',0.3);

    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.state(inrowdet_idx,2),'Color',colors.matlab{5}, 'DisplayName', bag2.log_name + " L");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.state(inrowdet_idx,1),'Color',colors.matlab{7}, 'DisplayName', bag2.log_name + " LF",'LineStyle','--','LineWidth',0.3);

    end

    if size(bag1.debug.stamp) == size(bag1.state.stamp)
        plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    end
    xlabel("timestamp [s]")
    ax(f-1).YTick = [-1 0 1 2];
    ax(f-1).YTickLabel = {'no_chunk','not fitted','fitted','discarded'};
    title("state ")
    legend show
    
    ax(f) = nexttile([2,1]); f=f+1;
    grid on; hold on;ylim(ax(f-1), [-1.5 2.5])
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.state(inrowdet_idx,3),'Color',colors.matlab{2}, 'DisplayName', bag1.log_name + " R");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.chunks.state(inrowdet_idx,4),'Color',colors.matlab{4}, 'DisplayName', bag1.log_name + " RF",'LineStyle','--','LineWidth',0.3);

    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.state(inrowdet_idx,3),'Color',colors.matlab{6}, 'DisplayName', bag2.log_name + " R");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.chunks.state(inrowdet_idx,4),'Color',colors.matlab{8}, 'DisplayName', bag2.log_name + " RF",'LineStyle','--','LineWidth',0.3);

    end
    if size(bag1.debug.stamp) == size(bag1.state.stamp)
        plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    end
    xlabel("timestamp [s]")
    ax(f-1).YTick = [-1 0 1 2];
    ax(f-1).YTickLabel = {'no_chunk','not fitted','fitted','discarded'};    title("state ")
    legend show
end
