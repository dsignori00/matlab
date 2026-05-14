%% IN ROW DET CHUNKS (visualize only if automatic inrow-det was enabled)
if (ismember(strategies,INROWDETSTR.AUTOMATIC))
    figure("Name","InRowDet - Closest Rows", 'NumberTitle','off');
    tiledlayout(3,2, "TileSpacing","compact")
    ax(f) = nexttile([1,2]); f=f+1;
    grid on; hold on;
    x_length(:,1) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,1,1) - bag1.debug.closest_lines.end_pt(inrowdet_idx,1,1)); 
    x_length(:,2) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,2,1) - bag1.debug.closest_lines.end_pt(inrowdet_idx,2,1));
    x_length(:,3) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,3,1) - bag1.debug.closest_lines.end_pt(inrowdet_idx,3,1)); 
    x_length(:,4) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,4,1) - bag1.debug.closest_lines.end_pt(inrowdet_idx,4,1));

    plot(bag1.debug.stamp(inrowdet_idx), x_length(:,2), 'DisplayName',bag1.log_name+  " L");
    plot(bag1.debug.stamp(inrowdet_idx), x_length(:,3), 'DisplayName', bag1.log_name + " R");
    plot(bag1.debug.stamp(inrowdet_idx), x_length(:,1), 'DisplayName', bag1.log_name + "LF",'LineStyle','--','LineWidth',0.3);
    plot(bag1.debug.stamp(inrowdet_idx), x_length(:,4), 'DisplayName', bag1.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    if compare 
        x_length2(:,1) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,1,1) - bag2.debug.closest_lines.end_pt(inrowdet_idx,1,1)); 
        x_length2(:,2) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,2,1) - bag2.debug.closest_lines.end_pt(inrowdet_idx,2,1));
        x_length2(:,3) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,3,1) - bag2.debug.closest_lines.end_pt(inrowdet_idx,3,1)); 
        x_length2(:,4) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,4,1) - bag2.debug.closest_lines.end_pt(inrowdet_idx,4,1));
        plot(bag1.debug.stamp(inrowdet_idx), x_length2(:,2), 'Color',colors.matlab{5} ,DisplayName', bag2.log_name+  " L");
        plot(bag1.debug.stamp(inrowdet_idx), x_length2(:,3), 'Color',colors.matlab{6} ,DisplayName', bag2.log_name + " R");
        plot(bag1.debug.stamp(inrowdet_idx), x_length2(:,1), 'Color',colors.matlab{7} ,DisplayName', bag2.log_name + "LF",'LineStyle','--','LineWidth',0.3);
        plot(bag1.debug.stamp(inrowdet_idx), x_length2(:,4), 'Color',colors.matlab{8} ,DisplayName', bag2.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    end
    if size(bag1.debug.stamp) == size(bag1.state.stamp)         
        plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);     
    end
    ylabel("x length")
    legend show
    
    ax(f) = nexttile([1,2]); f=f+1;
    grid on; hold on;
    y_length(:,1) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,1,2) - bag1.debug.closest_lines.end_pt(inrowdet_idx,1,2)); 
    y_length(:,2) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,2,2) - bag1.debug.closest_lines.end_pt(inrowdet_idx,2,2));
    y_length(:,3) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,3,2) - bag1.debug.closest_lines.end_pt(inrowdet_idx,3,2)); 
    y_length(:,4) = abs(bag1.debug.closest_lines.start_pt(inrowdet_idx,4,2) - bag1.debug.closest_lines.end_pt(inrowdet_idx,4,2)); 
    plot(bag1.debug.stamp(inrowdet_idx), y_length(:,2), 'DisplayName',bag1.log_name+  " L");
    plot(bag1.debug.stamp(inrowdet_idx), y_length(:,3), 'DisplayName', bag1.log_name + " R");
    plot(bag1.debug.stamp(inrowdet_idx), y_length(:,1), 'DisplayName', bag1.log_name + "LF",'LineStyle','--','LineWidth',0.3);
    plot(bag1.debug.stamp(inrowdet_idx), y_length(:,4), 'DisplayName', bag1.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    if compare 
        y_length2(:,1) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,1,2) - bag2.debug.closest_lines.end_pt(inrowdet_idx,1,2)); 
        y_length2(:,2) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,2,2) - bag2.debug.closest_lines.end_pt(inrowdet_idx,2,2));
        y_length2(:,3) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,3,2) - bag2.debug.closest_lines.end_pt(inrowdet_idx,3,2)); 
        y_length2(:,4) = abs(bag2.debug.closest_lines.start_pt(inrowdet_idx,4,2) - bag2.debug.closest_lines.end_pt(inrowdet_idx,4,2));
        plot(bag1.debug.stamp(inrowdet_idx), y_length2(:,2), 'Color',colors.matlab{5} ,DisplayName', bag2.log_name+  " L");
        plot(bag1.debug.stamp(inrowdet_idx), y_length2(:,3), 'Color',colors.matlab{6} ,DisplayName', bag2.log_name + " R");
        plot(bag1.debug.stamp(inrowdet_idx), y_length2(:,1), 'Color',colors.matlab{7} ,DisplayName', bag2.log_name + "LF",'LineStyle','--','LineWidth',0.3);
        plot(bag1.debug.stamp(inrowdet_idx), y_length2(:,4), 'Color',colors.matlab{8} ,DisplayName', bag2.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    end
    if size(bag1.debug.stamp) == size(bag1.state.stamp)         
        plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);     
    end
    ylabel("y length")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,2), 'DisplayName', bag1.log_name+  " L");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,3), 'DisplayName', bag1.log_name + " R");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,1), 'DisplayName', bag1.log_name + "LF",'LineStyle','--','LineWidth',0.3);
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,4), 'DisplayName', bag1.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,2), 'DisplayName', bag2.log_name+  " L");
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,3), 'DisplayName', bag2.log_name + " R");
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,1), 'DisplayName', bag2.log_name + "LF",'LineStyle','--','LineWidth',0.3);
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p1(inrowdet_idx,4), 'DisplayName', bag2.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    end
    if size(bag1.debug.stamp) == size(bag1.state.stamp)
        plot_patches(bag1.debug.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);
    end
    xlabel("time [s]")
    ylabel("Slope (m)")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,2), 'DisplayName', bag1.log_name+  " L");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,3), 'DisplayName', bag1.log_name + " R");
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,1), 'DisplayName', bag1.log_name + "LF",'LineStyle','--','LineWidth',0.3);
    plot(bag1.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,4), 'DisplayName', bag1.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    if compare 
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,2), 'DisplayName', bag2.log_name+  " L");
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,3), 'DisplayName', bag2.log_name + " R");
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,1), 'DisplayName', bag2.log_name + "LF",'LineStyle','--','LineWidth',0.3);
        plot(bag2.debug.stamp(inrowdet_idx), bag1.debug.closest_lines.p2(inrowdet_idx,4), 'DisplayName', bag2.log_name + "RF",'LineStyle','--','LineWidth',0.3);
    end
    if size(bag1.debug.stamp) == size(bag1.state.stamp)         
        plot_patches(bag1.state.stamp(inrowdet_idx), ~bag1.state.in_row(inrowdet_idx), ax(f-1), patch_properties);     
    end
    xlabel("time [s]")
    ylabel("Intercept (q)")
    legend show
end
