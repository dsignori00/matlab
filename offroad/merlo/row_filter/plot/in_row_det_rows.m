%% IN ROW DET CHUNKS (visualize only if automatic inrow-det was enabled)
if (ismember(strategies,INROWDETSTR.AUTOMATIC))
    figure("Name","InRowDet - Closest Rows");
    tiledlayout(3,2, "TileSpacing","compact")
    ax(f) = nexttile([1,2]); f=f+1;
    grid on; hold on;
    x_length(:,1) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,1,1) - bag1.debug.closest_lines.end_pt(inrowdet_idx,1,1)); 
    x_length(:,2) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,2,1) - bag1.debug.closest_lines.end_pt(inrowdet_idx,2,1)); 
    plot(bag1.debug.stamp(inrowdet_idx), x_length(:,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.debug.stamp(inrowdet_idx), x_length(:,2), 'DisplayName',bag1.log_name+  " R");
    if compare 
        x_length2(:,1) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,1,1) - bag2.debug.closest_lines.end_pt(inrowdet_idx,1,1)); 
        x_length2(:,2) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,2,1) - bag2.debug.closest_lines.end_pt(inrowdet_idx,2,1)); 
        plot(bag2.debug.stamp(inrowdet_idx), x_length2(:,1), 'DisplayName', bag2.log_name + " L");
        plot(bag2.debug.stamp(inrowdet_idx), x_length2(:,2), 'DisplayName',bag2.log_name+  " R");
    end
    plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    ylabel("x length")
    legend show
    
    ax(f) = nexttile([1,2]); f=f+1;
    grid on; hold on;
    y_length(:, 1) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,1,2) - bag1.debug.closest_lines.end_pt(inrowdet_idx,1,2)); 
    y_length(:, 2) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,2,2) - bag1.debug.closest_lines.end_pt(inrowdet_idx,2,2)); 
    plot(bag1.debug.stamp(inrowdet_idx), y_length(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.debug.stamp(inrowdet_idx), y_length(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    if compare 
        y_length2(:, 1) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,1,2) - bag2.debug.closest_lines.end_pt(inrowdet_idx,1,2)); 
        y_length2(:, 2) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,2,2) - bag2.debug.closest_lines.end_pt(inrowdet_idx,2,2)); 
        plot(bag2.debug.stamp(inrowdet_idx), y_length2(inrowdet_idx,1), 'DisplayName', bag2.log_name + " L");
        plot(bag2.debug.stamp(inrowdet_idx), y_length2(inrowdet_idx,2), 'DisplayName',bag2.log_name+  " R");
    end
    plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    ylabel("y length")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.closest_lines.p1(inrowdet_idx,1), 'DisplayName', bag2.log_name + " L");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.closest_lines.p1(inrowdet_idx,2), 'DisplayName',bag2.log_name+  " R");
    end
    plot_patches(bag1.debug.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    ylabel("Slope (m)")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.closest_lines.p2(inrowdet_idx,1), 'DisplayName', bag2.log_name + " L");
        plot(bag2.debug.stamp(inrowdet_idx), bag2.debug.closest_lines.p2(inrowdet_idx,2), 'DisplayName',bag2.log_name+  " R");
    end
    plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    ylabel("Intercept (q)")
    legend show
end